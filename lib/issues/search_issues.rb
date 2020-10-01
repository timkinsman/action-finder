# frozen_string_literal: true

require 'octokit'
require 'csv'
require 'json'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def find_issues(user, pass, input, file)
    client = authenticate(user, pass)

    CSV.open("data/issues.csv", 'w') do |csv|
        CSV.foreach(input, headers: true) do |action|
            next if action[1].include? "Utilities"
            action = action[0]
            CSV.foreach(file, headers: true) do |repo|
                next unless JSON.parse(repo[3]).any? { |a| a.include?(action) }
                repo = repo[0]
                spinner = TTY::Spinner.new("[:spinner] Checking if #{repo} has issues involving #{action.split('/')[-1]} ...", format: :classic)
                spinner.auto_spin
                client = authenticate(user, pass)
                check_rate_limit(client, 50, spinner)
                sleep(2)
                begin
                    issue = client.search_issues("\"github action\" OR \"github actions\" OR #{action.split('/')[0]} OR #{action.split('/')[-1]} repo:#{repo} comments:>0 updated:>=2019-11-13").items # type:issue

                    if issue.empty?
                        spinner.error
                        next
                    end

                    issue_collection = []
                    issue.each do |issue_i|
                           issue_collection << issue_i.html_url
                    end
                    next if issue_collection.empty?
                    csv << [repo, action, issue_collection]
                rescue
                    spinner.error
                    next
                end
                spinner.success
            end
        end
    end
end

find_issues(ARGV[0], ARGV[1], 'data/actions_metadata.csv', 'data/actions.csv')

