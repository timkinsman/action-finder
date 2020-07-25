# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def find_actions(dir)
  spinner = TTY::Spinner.new("[:spinner] Finding actions ...", format: :classic)
  spinner.auto_spin
  Dir.glob("#{dir}/workflows/**/*.{yml,yaml}") do |file|
    File.open(file) do |f|
      f.each_line do |line|
        if line =~ /uses:/
          puts "Found #{file}: #{line}"
        end
      end
    end
  end
  spinner.success
end
