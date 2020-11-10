# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def get_lang

    language = ["C", "C++", "C#", "Java", "Python", "Ruby", "PHP"]

    language.each do |lang|
        spinner = TTY::Spinner.new("[:spinner] Get #{lang} ...", format: :classic)

        CSV.open("data//language/all_#{lang}.csv", 'w') do |csv|
            csv << CSV.read("data/all_final.csv", headers: true).headers

            CSV.foreach('data/all_final.csv') do |row|
                csv << row if row[16] == lang
            end
        end

        spinner.success
    end
end

get_lang