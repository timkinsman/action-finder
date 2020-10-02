# frozen_string_literal: true

require 'open-uri'
require 'tty-spinner'
require 'zlib'

def get_dataset
  spinner = TTY::Spinner.new('[:spinner] Get dataset ...', format: :classic)
  spinner.auto_spin

  source = URI.open('https://reporeapers.github.io/static/downloads/dataset.csv.gz')
  gz = Zlib::GzipReader.new(source)
  result = gz.read
  Dir.mkdir 'data' unless File.exist?('data')
  File.write('data/dataset.csv', result)

  CSV.open('data/dataset_final.csv', 'w') do |csv|
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
    CSV.foreach('data/dataset.csv', headers: true) do |row|
      csv << row if row[13] == '1' or row[15] == '1'
    end
  end

  spinner.success
end
