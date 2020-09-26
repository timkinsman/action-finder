# frozen_string_literal: true

require 'csv'
require 'json'

def use_action(action)
    CSV.open("use_#{action.gsub('/', '_').gsub('-', '_')}.csv", 'w') do |csv|
        csv << ["repository"]
        CSV.foreach("data/actions.csv", headers: true) do |row|   
            next unless JSON.parse(row[3]).any? { |a| a.include?(action) }
            csv << row
        end
    end
end

use_action 'codecov/codecov-action'
