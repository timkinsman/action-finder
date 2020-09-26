require 'diffy'

def get_diff(file1, file2)
    puts Diffy::Diff.new(file1, file2, source: 'files').to_s(:color)

    with_block = false
    with_space = 0

    root_action = false

    tmp_file = []

    Diffy::Diff.new(file1, file2, source: 'files').each do |line|
        with_block = false if line[1..-1][/\A */].size != with_space + 2 

        if line =~ /\suses:/
            if line.include? './'
                root_action = true 
                next
            end
            root_action = false

            tmp_file << [line]
        end

        if line =~ /\swith:/ && root_action == false
            with_block = true
            with_space = line[1..-1][/\A */].size
        end

        if with_block == true
            tmp_file << [line]
        end
    end

    puts tmp_file
end

get_diff('data/workflows_commit_history/sebastianbergmann/phpunit/ci/2020-04-10_05-47-27_UTC_ci.yml', 'data/workflows_commit_history/sebastianbergmann/phpunit/ci/2020-09-11_13-00-42_UTC_ci.yml')
