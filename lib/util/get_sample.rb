# frozen_string_literal: true

require 'csv'
require 'set'
require 'json'

def rand_n(n, max)
    randoms = Set.new
    loop do
        randoms << rand(1..max)
        return randoms.to_a if randoms.size >= n
    end
end

def action_sample
    rand_sample = rand_n(237, 620)

    CSV.open("./data/action_sample_no_docker.csv", 'w') do |csv|
        csv << ["action"]
        CSV.foreach("./data/actions_ranked_no_docker.csv", headers: true).with_index(1) do |row, rowno|   
            next unless rand_sample.include? rowno
            csv << [row[0], row[1]]
        end
    end
end

action_sample
