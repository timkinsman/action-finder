require 'octokit'
require 'csv'
require 'json'
require 'tty-spinner'

require_relative 'util/authenticate'
require_relative 'util/check_rate_limit'

def find_issues(user, pass, input, file)
    client = authenticate(user, pass)
    CSV.foreach(input, headers: true) do |action|
        next if action[1].include? "Utilities"
        action = action[0]
        CSV.foreach(file, headers: true) do |repo|
            next unless JSON.parse(repo[3]).any? { |a| a.include?(action) }
            repo = repo[0]
            spinner = TTY::Spinner.new("[:spinner] Checking if #{repo} has issues involving #{action} ...", format: :classic)
            spinner.auto_spin
            client = authenticate(user, pass)
            check_rate_limit(client, 0, spinner)
            sleep(2)
            begin
                issue = client.search_issues("#{action} in:title,body,comments repo:#{repo} type:issue comments:>0 updated:>=2019-11-13").items
                if issue.empty?
                    spinner.error
                    next
                end

                iss_arr = []
                issue.each do |iss|
                    iss_arr << iss.html_url
                end
                File.open('data/issues.txt', 'a') { |f| f.write("#{repo},#{action},#{iss_arr}\n") }
            rescue
                spinner.error
                next
            end
            spinner.success
        end
    end
end

find_issues('timkinsman', '530qgpOV6S3f', 'data/actions_metadata.csv', 'data/actions.csv')

