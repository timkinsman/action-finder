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
            if line.split('@')[0].include? '.' or !(line.split('@')[0].include? '/')
                discard_action = true
                next
            end
            discard_action = false

            case line
                when /^-/ then 
                    line[0] = '*' # - collision issues
                    diff_file << [line]
                else diff_file << [line]
            end
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

def add_hash(hash, action, key)
    if hash[action].has_key? key
        hash[action][key] += 1
    else
        hash[action][key] = 1
    end
end

def minus_hash(hash, action, key)
    hash[action][key] -= 1
end

def calculate_diff(prev_file, next_file, hash)
    diff_file = get_diff(prev_file, next_file)

    action = ""
    actions_array = []
    arguments_modified = false
    existing_action = false
    possible_version_change = false

    diff_file.each do |line|
        is_with = true # assume it's a with block
        verson_change = false

        if line[0] =~ /\suses:/
            is_with = false
            action_split = action.split('@')[0].gsub('"', '').gsub("'", '') unless action.empty?

            if arguments_modified == true
                add_hash(hash, action_split, 'modifed')
                arguments_modified = false
            end

            if possible_version_change && line[0].start_with?('+')
                if action.split('@')[0] == line[0].gsub(/\s+/, "")[/(?<=uses:).*/].split('@')[0] && action != line[0].gsub(/\s+/, "")[/(?<=uses:).*/]
                    add_hash(hash, action_split, 'version_changed')
                    minus_hash(hash, action_split, 'removed')
                    possible_version_change = false
                    next
                end
            end

            action = line[0].gsub(/\s+/, "")[/(?<=uses:).*/]
            next if action.empty?
            action_split = action.split('@')[0].gsub('"', '').gsub("'", '')

            if line[0].start_with?('*')
                existing_action = false
                possible_version_change = true
                add_hash(hash, action_split, 'removed')
            elsif line[0].start_with?('+')
                existing_action = false
                possible_version_change = false
                add_hash(hash, action_split, 'added')
                actions_array << action_split
            else
                existing_action = true
                possible_version_change = false
            end
        end

        if existing_action && is_with && (line[0].start_with?('*') || line[0].start_with?('+'))
            arguments_modified = true
        end
    end

    actions_array.uniq
end

def get_actions
    spinner = TTY::Spinner.new("[:spinner] Get actions ...", format: :classic)
    spinner.auto_spin

    hash = Hash.new{ |h, k| h[k] = Hash.new(&h.default_proc) }
    temp = Tempfile.new

    CSV.open('data/actions_used.csv', 'w') do |csv|
        csv << ['repository', "actions"]

        Dir.foreach('data/workflows') do |user|
            next if user == '.' or user == '..'

            Dir.foreach("data/workflows/#{user}") do |repo|
                next if repo == '.' or repo == '..'
                actions = []

                Dir.foreach("data/workflows/#{user}/#{repo}") do |workflows|
                    next if workflows == '.' or workflows == '..'
                    prev_file = temp.path

                    Dir.foreach("data/workflows/#{user}/#{repo}/#{workflows}") do |workflow|
                        next if workflow == '.' or workflow == '..'

                        Dir.glob("data/workflows/#{user}/#{repo}/#{workflows}/#{workflow}") do |file|
                            actions = actions + calculate_diff(prev_file, file, hash)
                            prev_file = file
                        end

                    end
                end

                csv << ["#{user}/#{repo}", actions.uniq]
            end
        end
    end

    hash.each do |h|
        h[1]['added'] = 0 if h[1]['added'] == {}
        h[1]['removed'] = 0 if h[1]['removed'] == {}
        h[1]['modifed'] = 0 if h[1]['modifed'] == {}
        h[1]['version_changed'] = 0 if h[1]['version_changed'] == {}
    end


    CSV.open('data/actions.csv', 'w') do |csv|
        csv << ['action', 'added', 'removed', 'modifed', 'version_changed']
        hash.each do |h|
            csv << [h[0], h[1]['added'], h[1]['removed'], h[1]['modifed'], h[1]['version_changed']]
        end
    end

    spinner.success
end
