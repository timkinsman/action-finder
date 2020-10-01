# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def find_workflows(user, pass, input, output, dir)
  client = authenticate(user, pass)

  CSV.open(output, 'w') do |csv|
    csv << ["repository", "workflow_files", "workflow_files_count"]
    CSV.foreach(input, headers: true) do |row|
      spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has workflows ...", format: :classic)
      spinner.auto_spin

      begin
        client = authenticate(user, pass)
        check_rate_limit(client, 0, spinner)

        if client.repository?(row[0])
          workflows = client.contents(row[0], path: '.github/workflows')
          workflow_arr = []
          workflows.each do |wf|
            next if !(File.extname(wf.name) == '.yml' || File.extname(wf.name) == '.yaml') # next if not a workflow file
            workflow_arr << wf.name

            begin
              FileUtils.mkdir_p "#{dir}/#{row[0]}" unless File.exist?("#{dir}/#{row[0]}")
              download = URI.open(wf.download_url)
              IO.copy_stream(download, "#{dir}/#{row[0]}/#{wf.name}")
            rescue StandardError
              next
            end
            
          end
          csv << [row[0], workflow_arr, workflow_arr.length] unless workflow_arr.empty?
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
