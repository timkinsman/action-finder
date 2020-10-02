# frozen_string_literal: true

require 'csv'
require 'json'
require 'mechanize'
require 'tty-spinner'

def web_scrape_issues
    agent = Mechanize.new
    CSV.open('data/issues_final.csv', 'w') do |csv|
        CSV.foreach('data/issues.csv') do |row|
            spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has issues involving #{row[1]} ...", format: :classic)
            spinner.auto_spin

            JSON.parse(row[2]).each do |url|
                next if url.include?('pull') # next if pull request

                sleep(1)

                begin
                    page = agent.get(url)
                rescue Mechanize::ResponseCodeError # 429 => Net::HTTPTooManyRequests
                    spinner.error('429 => Net::HTTPTooManyRequests')
                    redo
                end
                body = page.body.downcase
                csv << [row[0], row[1], url] if [row[1]].any? { |keyword| body.include? keyword } #, 'github action', 'github actions'
            end

            spinner.success
        end
    end
end
