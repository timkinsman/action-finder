# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

Dir[File.join(__dir__, 'ts', '*.rb')].each { |file| require file }

def median_of a 
    return 0.0 if a.empty?
    sorted = a.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0 
end 

def time_series(token)
    client = authenticate(token)

    client.auto_paginate = true

    CSV.open('data/time_series.csv', 'a+') do |ts|
        ts << [
            "owner",
            "repo",
            "action",
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
            "action_primary_category",
            "action_secondary_category",
            "_merge"]
    end

    tmp = []

    CSV.foreach('data/adoption_date.csv', headers: true).with_index do |row, i|
        spinner = TTY::Spinner.new("[:spinner] #{row[0]}, #{row[1]} time series ...", format: :classic)
        spinner.auto_spin

        if !tmp.empty? && row[0] == tmp[-1][21] && ((DateTime.strptime(row[4], '%Y-%m-%d') >> 6) - 15) == DateTime.strptime(tmp[-1][3], '%Y-%m-%d')
            CSV.open('data/time_series.csv', 'a+') do |ts|
                tmp.each do |tmprow|
                    tmprow[0] = row[0].split('/')[0]
                    tmprow[1] = row[0].split('/')[1]
                    tmprow[2] = row[1]
                    tmprow[21] = row[0]
                    tmprow[24] = row[2]
                    tmprow[25] = row[3]
                    
                    ts << tmprow
                end
            end
        else
            tmp = []
            begin
                date = DateTime.strptime(row[4], '%Y-%m-%d')
                points = [
                    (date << 7) + 15,
                    (date << 6) + 15,
                    (date << 5) + 15,
                    (date << 4) + 15,
                    (date << 3) + 15,
                    (date << 2) + 15,
                    (date << 1) + 15,
                    (date >> 1) - 15,
                    (date >> 2) - 15,
                    (date >> 3) - 15,
                    (date >> 4) - 15,
                    (date >> 5) - 15,
                    (date >> 6) - 15,
                    (date >> 7) - 15
                ]

                lang = CSV.foreach('data/dataset_final.csv').select{ |data| data[0] == row[0] }[0][1]
                commits = client.contribs(row[0]).map { |item| item.contributions }.sum

                age_at_bot = pr_age(token, spinner, row[0], date)
                age_at_bot = 0 if age_at_bot < 0

                13.times do |i|
                    client = authenticate(token)
                    check_rate_limit(client, 10, spinner) # 10 call buffer

                    client.auto_paginate = true

                    time_after = i - 6
                    time_after = 0 if time_after < 0

                    merged = client.search_issues("repo:#{row[0]} is:pr is:merged closed:#{points[i]}..#{points[i + 1]}").items
                    sleep(2)
                    
                    nonmerged = client.search_issues("repo:#{row[0]} is:pr is:unmerged closed:#{points[i]}..#{points[i + 1]}").items
                    sleep(2)

                    opened = client.search_issues("repo:#{row[0]} is:pr created:#{points[i]}..#{points[i + 1]}").total_count
                    sleep(2)

                    tmp << [
                        row[0].split('/')[0],
                        row[0].split('/')[1],
                        row[1],
                        points[i].strftime("%Y-%m-%d"),
                        points[i + 1].strftime("%Y-%m-%d"),
                        i + 1,
                        i == 6 ? '' : (points[i] >= date).to_s.upcase,
                        i == 6 ? '' : time_after,
                        merged.count,
                        nonmerged.count,
                        median_of(pr_comments(merged)),
                        median_of(pr_comments(nonmerged)),
                        median_of(pr_time_to(pr_created_at(merged), pr_closed_at(merged))),
                        median_of(pr_time_to(pr_created_at(nonmerged), pr_closed_at(nonmerged))),
                        median_of(pr_commits(token, spinner, row[0], merged)),
                        median_of(pr_commits(token, spinner, row[0], nonmerged)),
                        lang,
                        '',
                        commits,
                        opened,
                        age_at_bot,
                        row[0],
                        i + 1,
                        0, # bot_comments
                        row[2],
                        row[3],
                        'left_only']                  

                end

                CSV.open('data/time_series.csv', 'a+') do |ts|
                    tmp.each do |tmprow|
                        ts << tmprow
                    end
                end
            rescue => e # repository no longer exist
                #puts e
                spinner.error
                next
            end
        end
        spinner.success
    end
end
