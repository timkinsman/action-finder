# frozen_string_literal: true

require 'csv'
require 'date'

def get_adoption_date
    CSV.open('data/adoption_date.csv', 'w') do |csv|
        csv << ["repository", "action", "primary_category", "secondary_category", "action_adoption_date", "current_date"]

        Dir.foreach('data/workflows') do |user|
            next if user == '.' or user == '..'

            Dir.foreach("data/workflows/#{user}") do |repo|
                next if repo == '.' or repo == '..'
                workflow_dates = []
                actions_used = []
                six_month_period = false

                CSV.foreach('data/actions_used.csv') do |row|
                    actions_used = JSON.parse(row[1]) if row[0] == "#{user}/#{repo}"
                end 

                actions_used.each do |action|
                    Dir.foreach("data/workflows/#{user}/#{repo}") do |workflows|
                        next if workflows == '.' or workflows == '..'

                        Dir.foreach("data/workflows/#{user}/#{repo}/#{workflows}") do |workflow|
                            next if workflow == '.' or workflow == '..'
                            if File.readlines("data/workflows/#{user}/#{repo}/#{workflows}/#{workflow}").any?{|line| line.include?(action)}
                                workflow_dates << workflow[0..9]
                                break
                            end

                        end
                    end

                    current_date = DateTime.now << 7 # 6 months and instability period

                    action_category = ""
                    CSV.foreach('data/actions_final.csv') do |row|
                        action_category = row[1].split(", ") if row[0] == action
                    end

                    csv << ["#{user}/#{repo}", action, action_category[0], action_category[1], workflow_dates.min, DateTime.now] if DateTime.strptime(workflow_dates.min, '%Y-%m-%d') < current_date
                end
            end
        end
    end
end
