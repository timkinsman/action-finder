# frozen_string_literal: true

require 'open-uri'
require 'tty-spinner'
require 'zlib'

def download_dataset(output)
  spinner = TTY::Spinner.new('[:spinner] Downloading dataset from https://reporeapers.github.io ...', format: :classic)
  spinner.auto_spin

  source = URI.open('https://reporeapers.github.io/static/downloads/dataset.csv.gz')
  gz = Zlib::GzipReader.new(source)
  result = gz.read
  Dir.mkdir dir unless File.exist?(dir)
  File.write(output, result)

  spinner.success
end