# frozen_string_literal: true

require 'csv'

def get_adoption_date
    CSV.open('data/adoption_date.csv', 'w') do |csv|
        csv << ["repository", "workflow_adoption_date", "has_six_months"]

        Dir.foreach('data/workflows') do |user|
            next if user == '.' or user == '..'

            Dir.foreach("data/workflows/#{user}") do |repo|
                next if repo == '.' or repo == '..'
                has_six_months = false
                workflow_dates = []

                Dir.foreach("data/workflows/#{user}/#{repo}") do |workflows|
                    next if workflows == '.' or workflows == '..'

                    Dir.foreach("data/workflows/#{user}/#{repo}/#{workflows}") do |workflow|
                        next if workflow == '.' or workflow == '..'
                        workflow_dates << workflow[0..9]
                        break

                    end
                end

                date = Time.new().to_datetime - ((6*30) + 15) # - 6 months and instability period
                has_six_months = true if Date.parse(workflow_dates.min) < Date.parse("#{date.year}-#{date.month}-#{date.day}")
                csv << ["#{user}/#{repo}", workflow_dates.min, has_six_months]
            end
        end
    end
end
