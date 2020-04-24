# frozen_string_literal: true

require "csv"

def headers 
    %w[
      repository
      language
      architecture
      community
      continuous_integration
      documentation
      history
      issues
      license
      size
      unit_test
      stars
      scorebased_org
      randomforest_org
      scorebased_utl
      randomforest_utl
    ]
end

CSV.open("#{ARGV[0]}-merge.csv", "wb", write_headers: true, headers: headers) do |csv|
  Dir["#{ARGV[0]}/*.csv"].each do |path|
    CSV.foreach(path) do |row|
      csv << row
    end
  end
end
