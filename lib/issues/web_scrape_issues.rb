# frozen_string_literal: true

require 'csv'
require 'json'
require 'mechanize'
require 'tty-spinner'

def web_scrape_issues(input, output)
    agent = Mechanize.new
    CSV.open(output, 'w') do |csv|
        CSV.foreach(input) do |row|
            spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has issues involving #{row[1]} ...", format: :classic)
            spinner.auto_spin

            JSON.parse(row[2]).each do |url|
                next if url.include?('pull') # filter out pull requests

                sleep(1)

                begin
                    page = agent.get(url)
                rescue Mechanize::ResponseCodeError # 429 => Net::HTTPTooManyRequests
                    spinner.error('429 => Net::HTTPTooManyRequests')
                    sleep(60)
                    agent = Mechanize.new
                    redo
                end
                body = page.body.downcase
                csv << [row[0], row[1], url] if [row[1], 'github action', 'github actions'].any? { |keyword| body.include? keyword }
            end

            spinner.success
        end
    end
end
