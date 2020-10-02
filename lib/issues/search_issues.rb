# frozen_string_literal: true

require 'csv'
require 'json'
require 'octokit'
require 'tty-spinner'

require_relative '../util/authenticate'
require_relative '../util/check_rate_limit'

def find_issues(user, pass, input, file)
    client = authenticate(user, pass)

    CSV.open("data/issues.csv", 'w') do |csv|
        CSV.foreach(input, headers: true) do |action|
            next if action[1].include? "Utilities"
            action = action[0]
            CSV.foreach(file, headers: true) do |repo|
                next unless JSON.parse(repo[3]).any? { |a| a.include?(action) }
                repo = repo[0]
                spinner = TTY::Spinner.new("[:spinner] Checking if #{repo} has issues involving #{action.split('/')[1]} ...", format: :classic)
                spinner.auto_spin
                client = authenticate(user, pass)
                check_rate_limit(client, 50, spinner)
                sleep(2) # 30 client.search_issues calls per minute limit
                begin
                    response = client.search_issues("\"github action\" OR \"github actions\" OR #{action.split('/')[0]} OR #{action.split('/')[1]} repo:#{repo} comments:>0 updated:>=2019-11-13").items # type:issue

                    if response.empty?
                        spinner.error
                        next
                    end

                    issues = []
                    reponse.each do |issue|
                           issues << issue.html_url
                    end
                    next if issues.empty?
                    csv << [repo, action, issues]
                rescue
                    spinner.error
                    next
                end
                spinner.success
            end
        end
    end
end
