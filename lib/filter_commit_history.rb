# frozen_string_literal: true

require 'base64'
require 'csv'
require 'fileutils'
require 'octokit'
require 'tty-spinner'

require_relative 'authenticate'

def filter_commit_history(dir)
  spinner = TTY::Spinner.new("[:spinner] Filtering commit history ...", format: :classic)
  spinner.auto_spin

  total_commits = 0
  addtions = 0
  deletions = 0

  Dir.foreach("#{dir}") do |user|
    next if user == '.' || user == '..'

    Dir.foreach("#{dir}/#{user}") do |repo|
      next if repo == '.' || repo == '..'

      Dir.foreach("#{dir}/#{user}/#{repo}") do |workflow|
        next if workflow == '.' or workflow == '..'
        prev_actions = []

        Dir.foreach("#{dir}/#{user}/#{repo}/#{workflow}") do |workflow_history|
          next if workflow_history == '.' or workflow_history == '..'
          total_commits = total_commits + 1

          Dir.glob("#{dir}/#{user}/#{repo}/#{workflow}/#{workflow_history}") do |file|
            File.open(file) do |contents|
              active_actions = []             
              contents.each_line do |line|
                next unless line =~ /\suses:/
                next if line.gsub(/\s+/, "")[/(?<=uses:).*/].empty?
                next if line.gsub(/\s+/, "").start_with?('#')
                splitted = line.gsub(/\s+/, "")[/(?<=uses:).*/][/[^#]+/]
                if splitted.start_with?('docker://')
                  if splitted.count(':') > 1 then
                    active_actions << splitted.rpartition(':')[0]
                  else
                    active_actions << splitted
                  end
                else
                  active_actions << splitted.split('@')[0]
                end
              end
              active_actions.uniq!
              addtions = addtions + (active_actions - prev_actions).length
              deletions = deletions + (prev_actions - active_actions).length
              prev_actions = active_actions
            end
          end
        end
      end
    end
  end

  spinner.success

  puts "Total commits: #{total_commits}"
  puts "Total Action additions: #{addtions}"
  puts "Total Action deletions: #{deletions}"

end