# frozen_string_literal: true

require 'csv'
require 'tty-spinner'

def find_actions(output, dir)
  spinner = TTY::Spinner.new('[:spinner] Finding actions ...', format: :classic)
  spinner.auto_spin

  CSV.open(output, 'w') do |csv|
    csv << ["repository", "workflow_files", "workflow_files_count", "actions", "actions_count"]
    Dir.foreach(dir) do |user|
      next if user == '.' or user == '..'

      Dir.foreach("#{dir}/#{user}") do |repo|
        next if repo == '.' or repo == '..'
        workflows, actions, actions_length = [], [], []

        Dir.foreach("#{dir}/#{user}/#{repo}") do |workflow|
          next if workflow == '.' or workflow == '..'
          workflows << workflow

          Dir.glob("#{dir}/#{user}/#{repo}/#{workflow}") do |file|
            file_actions = []
            File.open(file) do |contents|
              contents.each_line do |line|
                next unless line =~ /\suses:/ and !line.gsub(/\s+/, "").start_with?('#')

                splitted = line.gsub(/\s+/, "")[/(?<=uses:).*/][/[^#]+/]
                next if splitted.include?('docker://')
                file_actions << splitted.split('@')[0]
              end
              actions << file_actions
              actions_length << action.length
            end
          end
        end
        csv << ["#{user}/#{repo}", workflows, workflows.length, actions, actions_length]
      end
    end
  end

  spinner.success
end
