# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'login'

def find_workflows(user, pass, input, output)
  login(user, pass)

  spinner = TTY::Spinner.new("[:spinner] Filtering ...", format: :classic)
  spinner.auto_spin

  CSV.open(output, "w") do |csv|
    CSV.foreach(input).with_index do |row|
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
      rescue StandardError
        next
      end
    end
  end

  spinner.success
end

find_workflows(ARGV[0], ARGV[1], ARGV[2], ARGV[3])
