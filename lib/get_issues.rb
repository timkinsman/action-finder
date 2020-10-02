# frozen_string_literal: true

require 'csv'
require 'json'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def get_issues(user, pass, file)
    client = authenticate(user, pass)

    CSV.open("data/issues.csv", 'w') do |csv|
        CSV.foreach('data/actions_final.csv', headers: true) do |actions_final|
            next if actions_final[1].include? "Utilities"
            action = actions_final[0]
            CSV.foreach('data/has_actions.csv', headers: true) do |has_actions|
                next unless JSON.parse(has_actions[1]).any? { |a| a.include?(action) }
                repo = has_actions[0]
                spinner = TTY::Spinner.new("[:spinner] Checking if #{repo} has issues involving #{action} ...", format: :classic)
                spinner.auto_spin
                client = authenticate(user, pass)
                check_rate_limit(client, 50, spinner)
                sleep(2) # 30 search calls per minute limit
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
