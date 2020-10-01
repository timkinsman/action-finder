# frozen_string_literal: true

require 'csv'
require 'json'
require 'mechanize'
require 'tty-spinner'

def issues_web_scraper(dir)
    agent = Mechanize.new
    CSV.foreach("#{dir}/issues-subset.csv") do |row|
        #spinner = TTY::Spinner.new("[:spinner] Checking if #{row[0]} has issues involving #{row[1]} ...", format: :classic)
        #spinner.auto_spin

        begin
            JSON.parse(row[2]).each do |url|            
                next if url.include?('pull') # filter out pull requests
                page = agent.get(url)
                body = page.body.downcase
                puts "#{row[0]} | #{row[1]} | #{url}" if [row[1], row[1].split('/')[-1], row[1].split('/')[-1], 'github action', 'github actions'].any? { |keyword| body.include? keyword }
            end
            #spinner.success
        rescue StandardError => e
            #spinner.error(e)
        end
    end
end

issues_web_scraper('data')