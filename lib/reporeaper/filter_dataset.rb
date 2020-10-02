# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def filter_dataset(input, output)
  spinner = TTY::Spinner.new('[:spinner] Filtering dataset ...', format: :classic)
  spinner.auto_spin

  CSV.open(output, 'w') do |csv|
    csv << [
      "repository",
      "language",
      "architecture",
      "community",
      "continuous_integration",
      "documentation",
      "history",
      "issues",
      "license",
      "size",
      "unit_test",
      "stars",
      "scorebased_org",
      "randomforest_org", # row[13]
      "scorebased_utl",
      "randomforest_utl" # row[15]
    ]
    CSV.foreach(input, headers: true) do |row|
      csv << row if row[13] == '1' or row[15] == '1'
    end
  end

  spinner.success
end
