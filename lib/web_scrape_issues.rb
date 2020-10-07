# frozen_string_literal: true

require 'csv'
require 'json'
require 'mechanize'
require 'tty-spinner'

def web_scrape_issues
    agent = Mechanize.new
    CSV.open('data/issues_final.csv', 'w') do |csv|
        CSV.foreach('data/issues.csv') do |row|
            spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has issues involving 'github action' or 'github actions' ...", format: :classic)
            spinner.auto_spin

            JSON.parse(row[1]).each do |url|
                begin
                    page = agent.get(url)
                    sleep(1) # web scraper cooldown
                rescue Mechanize::ResponseCodeError # 429 => Net::HTTPTooManyRequests
                    spinner.error('429 => Net::HTTPTooManyRequests')
                    redo
                end

                csv << [row[0], url] if ['github action', 'github actions'].any? { |keyword| page.body.downcase.include? keyword }
            end

            spinner.success
        end
    end
end
