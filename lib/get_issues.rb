# frozen_string_literal: true

require 'csv'
require 'json'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def get_issues(token)
    client = authenticate(token)

    CSV.open("data/issues.csv", 'w') do |csv|
        CSV.foreach('data/actions_used.csv', headers: true) do |row|
            spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has issues involving GitHub Actions ...", format: :classic)
            spinner.auto_spin
            client = authenticate(token)
            check_rate_limit(client, 50, spinner) # 10 call buffer
            
            begin
                response = client.search_issues("\"github action\" OR \"github actions\" repo:#{row[0]} is:issue comments:>0 updated:>=2019-11-13").items
                if response.empty?
                    spinner.error
                    next
                end

                issues = []

                response.each do |issue|
                    issues << issue.html_url
                end

                if issues.empty?
                    spinner.error
                    next
                end

                csv << [row[0], issues]
            rescue
                spinner.error
                next
            end

            sleep(2) # 30 search calls per minute limit
            spinner.success
        end
    end
end
