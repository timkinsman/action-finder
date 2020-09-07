# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def find_actions(dir, output)
  spinner = TTY::Spinner.new('[:spinner] Finding actions ...', format: :classic)
  spinner.auto_spin

  CSV.open(output, 'w') do |csv|
    Dir.foreach("#{dir}/workflows") do |user|
      next if user == '.' || user == '..'

      Dir.foreach("#{dir}/workflows/#{user}") do |repo|
        next if repo == '.' || repo == '..'
        row, workflows, actions, num_actions = [], [], [], []
        row[0] = "#{user}/#{repo}"

        Dir.foreach("#{dir}/workflows/#{user}/#{repo}") do |workflow|
          next if workflow == '.' || workflow == '..'
          workflows << workflow

          Dir.glob("#{dir}/workflows/#{user}/#{repo}/#{workflow}") do |file|
            action = []
            File.open(file) do |contents|
              contents.each_line do |line|
                if line =~ /uses:/
                  splitted = line.split(' ')[-1]
                  if splitted.start_with?('docker')
                    action << splitted.rpartition(':')[0]
                  else
                    action << splitted.split('@')[0]
                  end
                end
              end
              actions << action
              num_actions << action.length
            end
          end
        end
        row[1] = workflows
        row[2] = workflows.length
        row[3] = actions
        row[4] = num_actions
        csv << row
      end
    end
  end
  
  spinner.success
end
