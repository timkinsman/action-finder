# frozen_string_literal: true

require 'csv'
require 'json'
require 'set'

def rand_n(n, max)
    begin
        randoms = Set.new
        loop do
            randoms << rand(1..max)
            return randoms.to_a if randoms.size >= n
        end
    rescue StandardError => e
        puts e
    end
end

def get_sample(input, output, sample_size, dataset_size)
    begin
        rand_sample = rand_n(sample_size, dataset_size)
        CSV.open(output, 'w') do |csv|
            CSV.foreach(input, headers: true).with_index(1) do |row, rowno|   
                next unless rand_sample.include? rowno
                csv << row
            end
        end
    rescue StandardError => e
        puts e
    end
end
