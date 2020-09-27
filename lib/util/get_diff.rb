require 'csv'
require 'diffy'
require 'tempfile'
require 'tty-spinner'

temp = Tempfile.new
hash = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

def get_diff(file1, file2, dup, hash)
    ### to tmp_file

    with_block = false
    with_space = 0

    discard_action = false

    tmp_file = []

    Diffy::Diff.new(file1, file2, source: 'files').each do |line|
        with_block = false if line[1..-1][/\A */].size != with_space + 2 

        if line.split('#')[0] =~ /\suses:/
            if line.include? './' or line.include?("docker://")
                discard_action = true 
                next
            end
            discard_action = false

            tmp_file << [line]
        end

        if line =~ /\swith:/ && discard_action == false
            with_block = true
            with_space = line[1..-1][/\A */].size
        end

        if with_block == true
            tmp_file << [line]
        end
    end

    ###

    added = []
    removed = []
    modified_args = []
    version_change = []

    action = ""
    args_modified = false
    existing_action = false
    possible_version_change = false

    tmp_file.each_with_index do |line, index|
        is_with = true

        if line[0] =~ /\suses:/
            is_with = false 
            if args_modified == true
                if hash[action.split('@')[0].gsub('"', '')].has_key? 'modified_args'
                    hash[action.split('@')[0].gsub('"', '')]['modified_args'] = hash[action.split('@')[0].gsub('"', '')]['modified_args'] + 1
                else
                    hash[action.split('@')[0].gsub('"', '')]['modified_args'] = 1
                end
                args_modified = false
            end

            if possible_version_change && line[0].start_with?('+')
                if action.split('@')[0] == line[0].gsub(/\s+/, "")[/(?<=uses:).*/].split('@')[0] && action != line[0].gsub(/\s+/, "")[/(?<=uses:).*/]
                    if hash[action.split('@')[0].gsub('"', '')].has_key? 'version_changes'
                        hash[action.split('@')[0].gsub('"', '')]['version_changes'] = hash[action.split('@')[0].gsub('"', '')]['version_changes'] + 1
                    else
                        hash[action.split('@')[0].gsub('"', '')]['version_changes'] = 1
                    end
                    possible_version_change = false
                    next
                end
            end

            action = line[0].gsub(/\s+/, "")[/(?<=uses:).*/]

            next if action.nil? or action.empty?
            next if action.include?('.')

            if line[0].start_with?('-')
                existing_action = false
                possible_version_change = true
                if hash[action.split('@')[0].gsub('"', '')].has_key? 'removed'
                    hash[action.split('@')[0].gsub('"', '')]['removed'] = hash[action.split('@')[0].gsub('"', '')]['removed'] + 1
                else
                    hash[action.split('@')[0].gsub('"', '')]['removed'] = 1
                end
            elsif line[0].start_with?('+')
                existing_action = false
                possible_version_change = false
                if hash[action.split('@')[0].gsub('"', '')].has_key? 'added'
                    hash[action.split('@')[0].gsub('"', '')]['added'] = hash[action.split('@')[0].gsub('"', '')]['added'] + 1
                else
                    hash[action.split('@')[0].gsub('"', '')]['added'] = 1
                end
            else
                existing_action = true
                possible_version_change = false
            end
        end

        if existing_action && is_with && (line[0].start_with?('-') || line[0].start_with?('+'))
            args_modified = true
        end
    end
end

spinner = TTY::Spinner.new("[:spinner] Retrieving metadata on commit history ...", format: :classic)
spinner.auto_spin

Dir.foreach("data/workflows_commit_history") do |user|
    next if user == '.' || user == '..'

    Dir.foreach("data/workflows_commit_history/#{user}") do |repo|
        next if repo == '.' || repo == '..'

        Dir.foreach("data/workflows_commit_history/#{user}/#{repo}") do |workflow|
            next if workflow == '.' or workflow == '..'
            prev_file = temp.path

            Dir.foreach("data/workflows_commit_history/#{user}/#{repo}/#{workflow}") do |history|
                next if history == '.' or history == '..'

                Dir.glob("data/workflows_commit_history/#{user}/#{repo}/#{workflow}/#{history}") do |file|
                    get_diff(prev_file, file, true, hash)
                    prev_file = file
                end
            end
        end
    end
end

spinner.success

CSV.open('out.csv', 'w') do |csv|
    csv << ['action', 'added', 'removed', 'modified_args', 'version_changes']
    hash.each do |h|
        csv << [h[0], h[1]['added'], h[1]['removed'], h[1]['modified_args'], h[1]['version_changes']]
        #pp h[0]
        #pp h[1]['added']
        #pp h[1]['removed']
        #pp h[1]['modified_args']
        #pp h[1]['version_changes']
    end
end

#puts hash
