# frozen_string_literal: true

require 'csv'

CSV.open("#{ARGV[0]}-filter.csv", "w") do |csv|
  csv << %w[
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
  CSV.foreach(ARGV[0]) do |row|
    csv << row if row[13] == '1' || row[15] == '1'
  end
end
