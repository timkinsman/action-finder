# frozen_string_literal: true

require 'base64'
require 'csv'
require 'fileutils'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def retrieve_commit_history(user, pass, input, output)
    client = authenticate(user, pass)

    CSV.foreach(input, headers: true) do |row|
        row[1].gsub('[', '').gsub('"', '').gsub(']', '').split(', ') do |wf|
            spinner = TTY::Spinner.new("[:spinner] Retrieving #{row[0]}'s #{wf} commit history ...", format: :classic)
            spinner.auto_spin

            check_rate_limit(client, 0, spinner)
            commits = client.commits(row[0], path: ".github/workflows/#{wf}")
            check_rate_limit(client, commits.count, spinner)

            commits.reverse_each do |commit|
                dest = "#{output}/#{row[0]}/#{wf.rpartition('.')[0]}"
                date = "#{commit.commit.author.date.to_s.gsub(" ", "_").gsub(":", "-")}_#{wf}"
                begin
                    file = client.contents(row[0], path: ".github/workflows/#{wf}", ref: commit.sha)
                rescue StandardError # workflow file was deleted
                    FileUtils.mkdir_p dest unless File.exist?(dest)
                    File.open("#{dest}/#{date}", 'w') {|f| f.write('') }
                    next
                end
                enc = file.content
                plain = Base64.decode64(enc)
                FileUtils.mkdir_p dest unless File.exist?(dest)
                File.open("#{dest}/#{date}", 'w') {|f| f.write(plain) }
            end

            spinner.success
        end
    end
end
