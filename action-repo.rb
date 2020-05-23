# frozen_string_literal: true

require 'csv'
require 'octokit'

client = Octokit::Client.new(login: ARGV[0], password: ARGV[1])

puts 'Attempting to login.'

begin
  client.user
rescue StandardError
  abort('-Login unsuccessful (401 - Bad credentials)')
end

puts '-Login successful.'
puts 'Preparing to dig through 446843 repositories.'
puts '-Prepared to dig.'

time = Time.new
puts "Started digging at Current Time : #{time.inspect}"

active_repositories = 0

CSV.open("./out.csv", "w") do |csv|
  csv << ["repository", "workflows"]
  CSV.foreach("dataset-f.csv").with_index do |row, i|
    begin
      print "Digging through #{i} of 446843 (#{client.rate_limit().remaining} rate limited requests remaining)\r"
      $stdout.flush
      client = Octokit::Client.new(login: ARGV[0], password: ARGV[1])
      if client.rate_limit.remaining <= 0
        resets_in = client.rate_limit().resets_in + 60
        puts ''
        resets_in.times do |t|
          print "-Refreshing rate limit - resets in #{resets_in - t - 1} seconds.\r"
          $stdout.flush
          sleep(1)
        end
        puts ''
        puts '--Resuming'
        redo
      end
      if client.repository?(row[0])
        active_repositories += 1
        workflows = client.contents(row[0], path: ".github/workflows")
        arr = []
        workflows.each do |wf|
          arr << wf.name if File.extname(wf.name) == ".yml" || File.extname(wf.name) == '.yaml'
        end
        csv << [row[0], arr, arr.length] unless arr.empty?
      end
    rescue StandardError
      next
    end
  end
  puts ''
  puts 'Completed.'
end

time = Time.new
puts "Finished digging at Current Time : #{time.inspect}"

puts "#{active_repositories} of 446843 repositories are active"
