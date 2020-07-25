# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'authenticate'

def find_workflows(user, pass, input, output)
  authenticate(user, pass)

  CSV.open(output, "w") do |csv|
    CSV.foreach(input).with_index do |row|
      spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has workflows ...", format: :classic)
      spinner.auto_spin
      begin
        client = Octokit::Client.new(login: user, password: pass)
        if client.rate_limit.remaining <= 0
          (client.rate_limit().resets_in + 60).times do
            sleep(1)
          end
          redo
        end
        if client.repository?(row[0])
          workflows = client.contents(row[0], path: ".github/workflows")
          arr = []
          workflows.each do |wf|
            arr << wf.name if File.extname(wf.name) == ".yml" || File.extname(wf.name) == '.yaml'
          end
          csv << [row[0], arr, arr.length] unless arr.empty?
        end
        spinner.success
      rescue StandardError
        spinner.error("(error: #{row[0]} DNE)")
        next
      end
    end
  end
end
