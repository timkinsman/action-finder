# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def median_of a       
    return nil if a.empty?
    sorted = a.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0 
end 

def time_series(user, pass)
    client = authenticate(user, pass)

    CSV.open('data/time_series.csv', 'w') do |ts|
        ts << [
            "owner",
            "repo",
            "bot_x",
            "month_start",
            "month_end",
            "time",
            "intervention",
            "time_after_intervention",
            "merged",
            "nonmerged",
            "comments_merged",
            "comments_nonmerged",
            "close_time_merged",
            "close_time_nonmerged",
            "commits_merged",
            "commits_nonmerged",
            "lang",
            "total_number_pr_authors",
            "commits",
            "opened",
            "age_at_bot",
            "name",
            "index",
            "bot_comments",
            "bot_y",
            "sum",
            "_merge"
        ]
        CSV.foreach('data/adoption_date.csv', headers: true).with_index do |row, i|
            next row if row[2] == 'false' # No 6 month period

            spinner = TTY::Spinner.new("[:spinner] #{row[0]} time series ...", format: :classic)
            spinner.auto_spin

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
                    date + ((30*6) + 15)
                ]
                12.times do |i|
                    client = authenticate(user, pass)
                    check_rate_limit(client, 10, spinner) # 10 call buffer

                    time_after = i + 1 - 6
                    time_after = 0 if time_after < 0

                    ###
                    #  Merged PRs
                    #

                    merged = client.search_issues("repo:#{row[0]} is:pr is:merged closed:#{points[i]}..#{points[i + 1]}")
                    sleep(3)

                    merged_total_count = merged.total_count
                    merged_items = merged.items
                    merged_median_comments = median_of(merged_items.map { |item| item.comments })
                    merged_pr_authors = (merged_items.map { |item| item.user.login })


                    merged_created_at = merged_items.map { |item| item.created_at }
                    merged_closed_at = merged_items.map { |item| item.closed_at }

                    arr_merged_time = []
                    merged_created_at.select.each_with_index { |item, index| arr_merged_time << ((merged_closed_at[index].to_time - item.to_time) / 3600).round }
                    merged_time = median_of arr_merged_time

                    ###
                    #  Nonmerged PRs
                    #
                    
                    nonmerged = client.search_issues("repo:#{row[0]} is:pr is:unmerged closed:#{points[i]}..#{points[i + 1]}")
                    sleep(3)

                    nonmerged_total_count = nonmerged.total_count
                    nonmerged_items = nonmerged.items
                    nonmerged_median_comments = median_of(nonmerged_items.map { |item| item.comments })
                    nonmerged_pr_authors = (nonmerged_items.map { |item| item.user.login })

                    nonmerged_created_at = nonmerged_items.map { |item| item.created_at }
                    nonmerged_closed_at = nonmerged_items.map { |item| item.closed_at }

                    arr_nonmerged_time = []
                    nonmerged_created_at.select.each_with_index { |item, index| arr_nonmerged_time << ((nonmerged_closed_at[index].to_time - item.to_time) / 3600).round }
                    nonmerged_time = median_of arr_nonmerged_time

                    ###

                    total_num_pr_authors = ((merged_pr_authors + nonmerged_pr_authors).uniq).count

                    ts << [
                        row[0].split('/')[0],
                        row[0].split('/')[1],
                        '',
                        points[i].strftime("%Y-%m-%d"),
                        points[i + 1].strftime("%Y-%m-%d"),
                        i + 1,
                        (points[i] >= date).to_s.upcase,
                        time_after,
                        merged_total_count,
                        nonmerged_total_count,
                        merged_median_comments,
                        nonmerged_median_comments,
                        merged_time,
                        nonmerged_time,
                        0,
                        0,
                        '',
                        total_num_pr_authors,
                        '',
                        '',
                        0,
                        row[0],
                        i + 1,
                        0,
                        '',
                        '',
                        'left_only'
                    ]
                end
            rescue => e # repository no longer exist
                 puts e
                spinner.error
                next
            end

            spinner.success
        end
    end
end
