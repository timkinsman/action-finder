# frozen_string_literal: true

require 'csv'
require 'mechanize'
require 'tty-spinner'

def get_metadata(action, agent)
    metadata = ["", "", "false"]

    if action.count('/') < 1 then
        return false # not a valid action
    elsif action.count('/') > 1 then
        split = action.split('/')
        url = "https://github.com/#{split[0]}/#{split[1]}"
    else
        url = "https://github.com/#{action}"
    end

    begin
        page = agent.get(url)
    rescue
        return false # not a valid action
    end

    metadata[1] = page.search('p.f4.mt-3').text.strip

    begin
        marketplace = page.link_with(text: 'View on Marketplace').click
    rescue
        return metadata # Action not published
    end

    metadata[0] = marketplace.search('a.topic-tag.topic-tag-link.f6').text.strip.gsub("\n", "").gsub("  ", ", ")
    metadata[2] = "true" if marketplace.body.include?('Verified creator')

    metadata
end

def web_scrape_actions
    spinner = TTY::Spinner.new("[:spinner] Web scrape actions ...", format: :classic)
    spinner.auto_spin

    agent = Mechanize.new
    
    does_not_exist = []

    CSV.open('data/actions_final.csv', 'w') do |csv|
        csv << ["action", "categories", "verified", "added_n_times", "removed_n_times", "agrugments_modified_n_times", "version_changed_n_times", "about"]
        CSV.foreach('data/actions.csv', headers: true) do |row|
            metadata = get_metadata(row[0], agent)
            sleep(1) # web scraper cooldown
            if metadata == false
                does_not_exist << row[0]
                next
            end
            csv << [row[0], metadata[0], metadata[2], row[1], row[2], row[3], row[4], metadata[1]]
        end
    end
    
    spinner.success

    puts "Remove #{does_not_exist}"
end
