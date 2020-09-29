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

def action_sample(input, output)
    rand_sample = rand_n(237, 620)

    CSV.open(output, 'w') do |csv|
        csv << ["action","categories","about","verified","added_n_times","removed_n_times","agrugments_modified_n_times","version_changed_n_times"]
        CSV.foreach(input, headers: true).with_index(1) do |row, rowno|   
            next unless rand_sample.include? rowno
            csv << row
        end
    end
end

action_sample(ARGV[0], ARGV[1])
