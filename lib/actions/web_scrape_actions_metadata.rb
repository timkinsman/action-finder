# frozen_string_literal: true

require 'csv'
require 'mechanize'
require 'tty-spinner'

def get_metadata(repository, agent)
    metadata = ["", "", "false"]

    if repository.count('/') < 1 then
        return metadata
    end

    if repository.count('/') > 1 then
        partition = repository.partition('/')
        if partition[2].count('/') > 0 then
            url = "https://github.com/#{partition[0]}/#{partition[2].partition('/')[0]}"
        else
            url = "https://github.com/#{partition[0]}/#{partition[2]}"
        end
    else
        url = "https://github.com/#{repository}"
    end

    begin
        page = agent.get(url)
    rescue
        return metadata
    end

    metadata[1] = page.search('p.f4.mt-3').text.strip

    begin
        marketplace = page.link_with(text: 'View on Marketplace').click
    rescue
        return metadata
    end

    metadata[0] = marketplace.search('a.topic-tag.topic-tag-link.f6').text.strip.gsub("\n", "").gsub("  ", ", ")
    metadata[2] = "true" if marketplace.body.include?('Verified creator')

    metadata
end

def retrieve_actions_metadata(input, output)
    spinner = TTY::Spinner.new("[:spinner] Retrieving metadata on actions ...", format: :classic)
    spinner.auto_spin

    agent = Mechanize.new
    
    CSV.open(output, 'w') do |csv|
        csv << ["action", "categories", "verified", "added_n_times", "removed_n_times", "agrugments_modified_n_times", "version_changed_n_times", "about"]
        CSV.foreach(input, headers: true) do |row|
            metadata = get_metadata(repository, agent)
            csv << [row[0], metadata[0], metadata[2], row[1], row[2], row[3], row[4], metadata[1]]
            sleep(1)
        end
    end
    
    spinner.success
end
