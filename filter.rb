# frozen_string_literal: true

require 'csv'

puts 'Preparing to filter through 1853205 repositories.'
puts '-Prepared to filter.'

time = Time.new

puts "Started filtering at Current Time : #{time.inspect}"

CSV.open("./dataset-f.csv", "w") do |csv|
  csv << ["repository"]
  CSV.foreach("dataset.csv").with_index do |row, i|
    print "Filtering through #{i} of 1853205\r"
    $stdout.flush
      if row[13] == '1' || row[15] == '1'
        csv << [row[0]]
      end
  end
  puts ''
  puts 'Completed.'
end

time = Time.new

puts "Finished filtering at Current Time : #{time.inspect}"
