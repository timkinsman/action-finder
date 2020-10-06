# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def time_series(user, pass)
    client = authenticate(user, pass)

    CSV.open('data/time_series_issues.csv', 'w') do |ts_issues|
        CSV.open('data/time_series_pull.csv', 'w') do |ts_pull|
            ts_issues << [
                "repository",
                "open_issues_-6",
                "open_issues_-5",
                "open_issues_-4",
                "open_issues_-3",
                "open_issues_-2",
                "open_issues_-1",
                "open_issues_0",
                "open_issues_+1",
                "open_issues_+2",
                "open_issues_+3",
                "open_issues_+4",
                "open_issues_+5",
                "open_issues_+6"]
            ts_pull << [
                "repository",
                "open_pull_-6",
                "open_pull_-5",
                "open_pull_-4",
                "open_pull_-3",
                "open_pull_-2",
                "open_pull_-1",
                "open_pull_0",
                "open_pull_+1",
                "open_pull_+2",
                "open_pull_+3",
                "open_pull_+4",
                "open_pull_+5",
                "open_pull_+6",
                "merged_pull_-6",
                "merged_pull_-5",
                "merged_pull_-4",
                "merged_pull_-3",
                "merged_pull_-2",
                "merged_pull_-1",
                "merged_pull_0",
                "merged_pull_+1",
                "merged_pull_+2",
                "merged_pull_+3",
                "merged_pull_+4",
                "merged_pull_+5",
                "merged_pull_+6",
                "unmerged_pull_-6",
                "unmerged_pull_-5",
                "unmerged_pull_-4",
                "unmerged_pull_-3",
                "unmerged_pull_-2",
                "unmerged_pull_-1",
                "unmerged_pull_0",
                "unmerged_pull_+1",
                "unmerged_pull_+2",
                "unmerged_pull_+3",
                "unmerged_pull_+4",
                "unmerged_pull_+5",
                "unmerged_pull_+6"]
            CSV.foreach('data/adoption_date.csv', headers: true) do |row|
                next row if row[2] == 'false'

                spinner = TTY::Spinner.new("[:spinner] #{row[0]} time series ...", format: :classic)
                spinner.auto_spin

                client = authenticate(user, pass)
                check_rate_limit(client, 50, spinner) # 50 call buffer

                begin
                    date = DateTime.strptime(row[1], '%Y-%m-%d')
                    points = [
                        date - ((30*6) + 15),
                        date - ((30*5) + 15),
                        date - ((30*4) + 15),
                        date - ((30*3) + 15),
                        date - ((30*2) + 15),
                        date - ((30*1) + 15),
                        date,
                        date + ((30*1) + 15),
                        date + ((30*2) + 15),
                        date + ((30*3) + 15),
                        date + ((30*4) + 15),
                        date + ((30*5) + 15),
                        date + ((30*6) + 15)]

                    issues_row = []
                    issues_row << row[0]
                    points.each do |date_points|
                        issues_row << client.search_issues("repo:#{row[0]} is:issue is:open created:<#{date_points}").total_count
                        sleep(2) # 30 search calls per minute
                    end
                    ts_issues << issues_row

                    pr_row = []
                    pr_row << row[0]
                    points.each do |date_points|
                        pr_row << client.search_issues("repo:#{row[0]} is:pr is:open created:<#{date_points}").total_count
                        sleep(2) # 30 search calls per minute
                    end
                    #points.each do |date_points|
                    #    pr_row << client.search_issues("repo:#{row[0]} is:pr is:merged created:<#{date_points}").total_count
                    #    sleep(2) # 30 search calls per minute
                    #end
                    #points.each do |date_points|
                    #    pr_row << client.search_issues("repo:#{row[0]} is:pr is:unmerged created:<#{date_points}").total_count
                    #    sleep(2) # 30 search calls per minute
                    #end
                    ts_pull << pr_row
                rescue => e # repository does not exist
                    # puts e
                    spinner.error
                    next
                end

                spinner.success
            end
        end
    end
end