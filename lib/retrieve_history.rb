# frozen_string_literal: true

require 'base64'
require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'authenticate'

def retrieve_history(user, pass, input, output)
    authenticate(user, pass)

    CSV.open(output, 'w') do |csv|
        csv << ["repository", "workflow_file", "total_commits"]# "action_additions", "action_deletions", "total"]
        CSV.foreach(input, headers: true) do |row|
            row[1].gsub('[', '').gsub('"', '').gsub(']', '').gsub(' ', '').split(',') do |wf|
                spinner = TTY::Spinner.new("[:spinner] Retrieving #{row[0]}'s #{wf} commit history ...", format: :classic)
                spinner.auto_spin
                client = Octokit::Client.new(login: user, password: pass)
                if client.rate_limit.remaining <= 0
                    spinner.error('ERROR: Rate limit exceeded!')
                    spinner = TTY::Spinner.new("[:spinner] Rate limit resets in #{client.rate_limit.resets_in + 5} seconds ...", format: :classic)
                    spinner.auto_spin
          
                    sleep(client.rate_limit.resets_in + 5)
          
                    spinner.success
                    redo
                end
                commits = client.commits(row[0], path: ".github/workflows/#{wf}")
                #commits.reverse_each do |commit|
                #    enc = client.contents(row[0], path: ".github/workflows/#{wf}", ref: commit.sha).content
                #    plain = Base64.decode64(enc)
                #    actions = []
                #    plain.each_line do |line|
                #        next unless line =~ /\suses:/
                #        actions << line.split[-1].gsub('"', '')
                #    end
                #    pp actions
                #end
                csv << [row[0], wf, commits.count]

                spinner.success
            end
        end
    end

end