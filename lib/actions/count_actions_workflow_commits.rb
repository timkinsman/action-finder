# frozen_string_literal: true

require 'csv'
require 'diffy'
require 'tempfile'
require 'tty-spinner'

def get_diff(prev_file, next_file)
    with_block = false
    with_space = 0

    discard_action = false

    diff_file = []

    Diffy::Diff.new(prev_file, next_file, source: 'files').each do |line|
        with_block = false if line[1..-1][/\A */].size != with_space + 2 

        if line.split('#')[0] =~ /\suses:/
            if line.include? './' or line.include?("docker://")
                discard_action = true 
                next
            end
            discard_action = false

            diff_file << [line]
        end

        if line =~ /\swith:/ && discard_action == false
            with_block = true
            with_space = line[1..-1][/\A */].size
        end

        if with_block == true
            diff_file << [line]
        end
    end

    diff_file
end


def calculate_diff(prev_file, next_file, hash)
    diff_file = get_diff(prev_file, next_file)

    added_n_times = []
    removed_n_times = []
    arugments_modified_n_times = []
    version_changed_n_times = []

    action = ""
    arguments_modified = false
    existing_action = false
    possible_version_change = false

    diff_file.each_with_index do |line, index|
        is_with = true # assume it's a with block

        if line[0] =~ /\suses:/
            is_with = false 
            action_split = action.split('@')[0].gsub('"', '')

            if arguments_modified == true
                if hash[action_split].has_key? 'arugments_modified_n_times'
                    hash[action_split]['arugments_modified_n_times'] = hash[action_split]['arugments_modified_n_times'] + 1
                else
                    hash[action_split]['arugments_modified_n_times'] = 1
                end
                arguments_modified = false
            end

            if possible_version_change && line[0].start_with?('+')
                if action.split('@')[0] == line[0].gsub(/\s+/, "")[/(?<=uses:).*/].split('@')[0] && action != line[0].gsub(/\s+/, "")[/(?<=uses:).*/]
                    if hash[action_split].has_key? 'version_changed_n_times'
                        hash[action_split]['version_changed_n_times'] = hash[action_split]['version_changed_n_times'] + 1
                    else
                        hash[action_split]['version_changed_n_times'] = 1
                    end
                    possible_version_change = false
                    next
                end
            end

            action = line[0].gsub(/\s+/, "")[/(?<=uses:).*/]

            next if action.nil? or action.empty?
            next if action.include?('.')

            action_split = action.split('@')[0].gsub('"', '')

            if line[0].start_with?('-')
                existing_action = false
                possible_version_change = true
                if hash[action_split].has_key? 'removed_n_times'
                    hash[action_split]['removed_n_times'] = hash[action_split]['removed_n_times'] + 1
                else
                    hash[action_split]['removed_n_times'] = 1
                end
            elsif line[0].start_with?('+')
                existing_action = false
                possible_version_change = false
                if hash[action_split].has_key? 'added_n_times'
                    hash[action_split]['added_n_times'] = hash[action_split]['added_n_times'] + 1
                else
                    hash[action_split]['added_n_times'] = 1
                end
            else
                existing_action = true
                possible_version_change = false
            end
        end

        if existing_action && is_with && (line[0].start_with?('-') || line[0].start_with?('+'))
            arguments_modified = true
        end
    end
end

def filter_workflow_commits(output, dir)
    spinner = TTY::Spinner.new("[:spinner] Retrieving metadata on commit history ...", format: :classic)
    spinner.auto_spin

    hash = Hash.new{ |h, k| h[k] = Hash.new(&h.default_proc) }
    temp = Tempfile.new

    Dir.foreach(dir) do |user|
        next if user == '.' || user == '..'

        Dir.foreach("#{dir}/#{user}") do |repo|
            next if repo == '.' || repo == '..'

            Dir.foreach("#{dir}/#{user}/#{repo}") do |workflow|
                next if workflow == '.' or workflow == '..'
                prev_file = temp.path

                Dir.foreach("#{dir}/#{user}/#{repo}/#{workflow}") do |history|
                    next if history == '.' or history == '..'

                    Dir.glob("#{dir}/#{user}/#{repo}/#{workflow}/#{history}") do |file|
                        calculate_diff(prev_file, file, hash)
                        prev_file = file
                    end
                end
            end
        end
    end

    spinner.success

    CSV.open(output, 'w') do |csv|
        csv << ['action', 'added_n_times', 'removed_n_times', 'arugments_modified_n_times', 'version_changed_n_times']
        hash.each do |h|
            csv << [h[0], h[1]['added_n_times'], h[1]['removed_n_times'], h[1]['arugments_modified_n_times'], h[1]['version_changed_n_times']]
        end
    end
end
