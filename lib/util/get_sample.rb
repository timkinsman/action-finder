# frozen_string_literal: true

file = "./data/actions_ranked.csv"

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
    rand_sample = rand_n(244, 667)

    CSV.open("./data/action_sample.csv", 'w') do |csv|
        csv << ["action"]
        CSV.foreach(file, headers: true).with_index(1) do |row, rowno|   
            next unless rand_sample.include? rowno
            csv << [row[0], row[1]]
        end
    end
end
