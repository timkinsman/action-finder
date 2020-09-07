# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'octokit'
require 'tty-spinner'

require_relative 'authenticate'

def find_workflows(user, pass, input, output, dir)
  authenticate(user, pass)

  CSV.open(output, "w") do |csv|
    CSV.foreach(input).with_index do |row|
      spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has workflows ...", format: :classic)
      spinner.auto_spin

      begin
        client = Octokit::Client.new(login: user, password: pass)
        if client.rate_limit.remaining <= 4995
          spinner.error("ERROR: Rate limit exceeded!")
          spinner = TTY::Spinner.new("[:spinner] Rate limit resets in #{client.rate_limit().resets_in + 5} seconds ...", format: :classic)
          spinner.auto_spin

          sleep(client.rate_limit().resets_in + 5)

          spinner.success
          redo
        end
        if client.repository?(row[0])
          workflows = client.contents(row[0], path: ".github/workflows")
          arr = []
          FileUtils.mkdir_p "#{dir}/#{row[0]}"
          workflows.each do |wf|
            if File.extname(wf.name) == ".yml" || File.extname(wf.name) == '.yaml'
              arr << wf.name        
              begin
                download = URI.open(wf.download_url)
                IO.copy_stream(download, "#{dir}/#{row[0]}/#{wf.name}")
              rescue StandardError
                next
              end
            end
          end
          csv << [row[0], arr, arr.length] unless arr.empty?
        else
          spinner.error
          next
        end
      rescue StandardError
        spinner.error
        next
      end
      
      spinner.success
    end
  end
end
