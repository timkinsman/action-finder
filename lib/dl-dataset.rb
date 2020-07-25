# frozen_string_literal: true

require 'zlib' 
require 'open-uri'
require 'tty-spinner'

def dl_dataset(dir)
  spinner = TTY::Spinner.new("[:spinner] Downloading dataset from https://reporeapers.github.io ...", format: :classic)
  spinner.auto_spin
  uri = "https://reporeapers.github.io/static/downloads/dataset.csv.gz"
  source = open(uri)
  gz = Zlib::GzipReader.new(source) 
  result = gz.read
  Dir.mkdir dir unless File.exists?(dir)
  File.write("#{dir}/dataset.csv", result)
  spinner.success
end