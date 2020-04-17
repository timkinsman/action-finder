# frozen_string_literal: true

require 'csv'
require 'octokit'
require 'ruby-progressbar'

def check_if_exists(arr, client, data)
  progressbar = ProgressBar.create(
    format: '%a |%b>>%i| %p%% %t',
    total: 100
  )
  data.each do |row|
    client.contents("#{row[0]}", path: '.github/workflows')
    arr.append(row[0])
    progressbar.increment
  rescue StandardError
    progressbar.increment
  end
end

def create_client(login, password)
  client = Octokit::Client.new(login: login, password: password)
  abort_msg = "API rate limit exceeded. Try again in #{(client.rate_limit().resets_in/100.00).ceil()} minutes."
  abort(abort_msg) unless client.rate_limit().remaining >= 100
  client
rescue StandardError
  abort("Incorrect GitHub username or password. Please try again.")
end

def filter_dataset(arr, file)
  CSV.foreach(file) do |row|
    arr.append(row) if row[13] == '1' && row[15] == '1'
    break if arr.length == 100
  end
end

def action_finder()
  client = create_client(ARGV[0], ARGV[1])
  filter_dataset(filtered = [], './dataset.csv')
  check_if_exists(has_action = [], client, filtered)
  puts "The following use GitHub Actions:"
  pp has_action
  puts "#{has_action.length} of 100 (#{(has_action.length/100.00).round(2)}%) use GitHub Actions."
end

action_finder()