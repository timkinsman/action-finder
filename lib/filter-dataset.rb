# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def filter_dataset(input, output)
  spinner = TTY::Spinner.new("[:spinner] Filtering dataset ...", format: :classic)
  spinner.auto_spin

  CSV.open(output, "w") do |csv|
    CSV.foreach(input).with_index do |row, i|
      if row[13] == '1' || row[15] == '1'
        csv << [row[0]]
      end
    end
  end
  
  spinner.success
end
