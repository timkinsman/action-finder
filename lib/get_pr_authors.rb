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

def get_pr_authors(token)
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

        begin
            if tmp.empty? || row[0] != tmp[21]
                client = authenticate(token)
                check_rate_limit(client, 50, spinner)

                client.auto_paginate = true
                opened = client.pull_requests(row[0], state: 'open')
                closed = client.pull_requests(row[0], state: 'closed')
                pr = opened + closed

                tmp = [
                    row[0].split('/')[0],
                    row[0].split('/')[1],
                    row[1],
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    pr_authors(pr).uniq.count,
                    '',
                    '',
                    '',
                    row[0],
                    '',
                    '',
                    row[2],
                    row[3],
                    'left_only']  
            end

            CSV.open('data/time_series.csv', 'a+') do |ts|
                13.times do
                    ts << tmp
                end
            end

            spinner.success
            next
        rescue => e
            p e
            spinner.error           
            next
        end
    end
end
