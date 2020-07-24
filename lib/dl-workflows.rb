# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'open-uri'
require 'fileutils'
require 'tty-spinner'

require_relative 'login'

def dl_workflows(user, pass, input, output)
  client = login(user, pass)

  CSV.foreach(input).with_index do |row|
    spinner = TTY::Spinner::Multi.new("[:spinner] Downloading #{row[0]}'s' workflows ...", format: :classic)
    spinner.auto_spin
    FileUtils.mkdir_p "#{output}/#{row[0]}"
    workflows = row[1].tr('[\"]', '').split(', ')

    workflows.each do |wf|
      nested_sp = spinner.register "[:spinner] Downloading #{wf} ..."
      nested_sp.auto_spin
      begin
        url = client.contents("#{row[0]}", :path => ".github/workflows/#{wf}").download_url
        download = open(url)
        IO.copy_stream(download, "#{output}/#{row[0]}/#{wf}")
        nested_sp.success
      rescue StandardError
        nested_sp.error('(error)')
        next
      end
    end

    spinner.success
  end
end
