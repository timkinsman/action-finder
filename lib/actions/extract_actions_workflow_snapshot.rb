# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def find_actions(output, dir)
  spinner = TTY::Spinner.new('[:spinner] Finding actions ...', format: :classic)
  spinner.auto_spin

  commented_out = 0  
  CSV.open(output, 'w') do |csv|
    csv << ["repository", "workflow_files", "workflow_files_count", "actions", "actions_count"]
    Dir.foreach(dir) do |user|
      next if user == '.' || user == '..'

      Dir.foreach("#{dir}/#{user}") do |repo|
        next if repo == '.' || repo == '..'
        row, workflows, actions, num_actions = [], [], [], []
        row[0] = "#{user}/#{repo}"

        Dir.foreach("#{dir}/#{user}/#{repo}") do |workflow|
          next if workflow == '.' or workflow == '..'
          workflows << workflow

          Dir.glob("#{dir}/#{user}/#{repo}/#{workflow}") do |file|
            action = []
            File.open(file) do |contents|
              contents.each_line do |line|
                next unless line =~ /\suses:/
                if line.gsub(/\s+/, "").start_with?('#') then
                    #commented_out = commented_out + 1
                  next
                end
                splitted = line.gsub(/\s+/, "")[/(?<=uses:).*/][/[^#]+/]
                if splitted.include?('docker://')
                  next
                  if splitted.count(':') > 1 then
                    action << splitted.rpartition(':')[0]
                  else
                    action << splitted
                  end
                else
                  action << splitted.split('@')[0]
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
  puts "Number of actions commented out: #{commented_out}"
end
