# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'open-uri'
require 'fileutils'
require 'tty-spinner'

require_relative 'authenticate'

def dl_workflows(user, pass, input, output)
  client = authenticate(user, pass)

  CSV.foreach(input).with_index do |row|
    FileUtils.mkdir_p "#{output}/#{row[0]}"
    workflows = row[1].tr('[\"]', '').split(', ')

    workflows.each do |wf|
      spinner = TTY::Spinner.new("[:spinner] Downloading #{wf} from #{row[0]} ...", format: :classic)
      spinner.auto_spin
      begin
        url = client.contents("#{row[0]}", :path => ".github/workflows/#{wf}").download_url
        download = open(url)
        IO.copy_stream(download, "#{output}/#{row[0]}/#{wf}")
        spinner.success
      rescue StandardError
        spinner.error("(error) #{wf} DNE")
        next
      end
    end
  end
end
