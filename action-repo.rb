# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'ruby-progressbar'

def check_if_exists(client, file, index)
  progressbar = ProgressBar.create(format: '%a |%b>>%i| %p%% %t', total: 5000)
  arr = []
  CSV.foreach(file) do |row|
    client.contents("#{row[0]}", path: '.github/workflows')
    arr << row
    progressbar.increment
  rescue StandardError
    progressbar.increment
  end
  puts "#{file}: #{arr.length} out of 5000 (#{((arr.length/5000.00)*100).round(2)}%) use GitHub Actions"
  CSV.open("./result-files/result-files-#{index}.csv", "w") do |csv|
    arr.each do |row|
      csv << row
    end
  end
end

def create_client(login, password)
  client = Octokit::Client.new(login: login, password: password)
  abort_msg = "API rate limit exceeded. (#{client.rate_limit().resets_in} seconds remaining to refresh.)"
  abort(abort_msg) unless client.rate_limit().remaining == 5000
  client
rescue StandardError
  abort("Incorrect GitHub username or password. Please try again.")
end

def run()
  client = create_client(ARGV[0], ARGV[1])
  for index in 0..89
    check_if_exists(client, "./split-files/split-files-#{index}.csv", index)
    puts "Sleeping for #{client.rate_limit().resets_in + 300} seconds."
    sleep client.rate_limit().resets_in + 300
  end
end

run()
