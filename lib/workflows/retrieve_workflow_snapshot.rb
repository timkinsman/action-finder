# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'octokit'
require 'tty-spinner'

require_relative '../util/authenticate'
require_relative '../util/check_rate_limit'

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

        unless client.repository?(row[0]) # unless repository exists
          spinner.error
          next
        end

        workflows = client.contents(row[0], path: '.github/workflows')
        workflow_files = []

        workflows.each do |workflow|
          next unless File.extname(workflow.name) == '.yml' or File.extname(workflow.name) == '.yaml' # next unless a workflow file

          workflow_files << workflow.name
          begin
            FileUtils.mkdir_p "#{dir}/#{row[0]}" unless File.exist?("#{dir}/#{row[0]}")
            file = URI.open(workflow.download_url)
            IO.copy_stream(file, "#{dir}/#{row[0]}/#{workflow.name}")
          rescue StandardError # file does not exist
            next
          end
        end

        csv << [row[0], workflow_files, workflow_files.length] unless workflow_files.empty?
      rescue StandardError
        spinner.error
        next
      end

      spinner.success
    end
  end
end
