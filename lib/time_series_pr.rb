# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def time_series(user, pass)
    client = authenticate(user, pass)

    prior_workflow_adoption = []
    workflow_adoption = []
    after_workflow_adoption = []

    CSV.open('data/time_series.csv', 'w') do |csv|
        csv << [
            "repository",
            "open_issues_6mon_before_adoption",
            "open_issues_5mon_before_adoption",
            "open_issues_4mon_before_adoption",
            "open_issues_3mon_before_adoption",
            "open_issues_2mon_before_adoption",
            "open_issues_1mon_before_adoption",
            "open_issues_at_adoption",
            "open_issues_1mon_after_adoption",
            "open_issues_2mon_after_adoption",
            "open_issues_3mon_after_adoption",
            "open_issues_4mon_after_adoption",
            "open_issues_5mon_after_adoption",
            "open_issues_6mon_after_adoption",
            "closed_issues_6mon_before_adoption",
            "closed_issues_5mon_before_adoption",
            "closed_issues_4mon_before_adoption",
            "closed_issues_3mon_before_adoption",
            "closed_issues_2mon_before_adoption",
            "closed_issues_1mon_before_adoption",
            "closed_issues_at_adoption",
            "closed_issues_1mon_after_adoption",
            "closed_issues_2mon_after_adoption",
            "closed_issues_3mon_after_adoption",
            "closed_issues_4mon_after_adoption",
            "closed_issues_5mon_after_adoption",
            "closed_issues_6mon_after_adoption",
        ]
        CSV.foreach('data/adoption_date.csv', headers: true) do |row|
            next row if row[2] == 'false'

            spinner = TTY::Spinner.new("[:spinner] #{row[0]} time series ...", format: :classic)
            spinner.auto_spin

            client = authenticate(user, pass)
            check_rate_limit(client, 50, spinner) # 50 call buffer

            begin
                date = DateTime.strptime(row[1], '%Y-%m-%d')
    
                csv << [
                    row[0],
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 6}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 5}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 4}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 3}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 2}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date << 1}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 1}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 2}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 3}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 4}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 5}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date >> 6}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 6}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 5}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 4}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 3}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 2}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date << 1}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 1}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 2}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 3}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 4}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 5}").total_count,
                    client.search_issues("repo:#{row[0]} is:issue is:closed created:<#{date >> 6}").total_count
                ]

                sleep(60) # 30 search calls per minute
            rescue # repository does not exist
                spinner.error
                next
            end

            spinner.success
        end
    end
end