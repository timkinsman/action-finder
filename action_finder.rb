require 'octokit'

def checkIfExists(owner, repo)
    begin  
        pp Octokit.contents("#{owner}/#{repo}", path: '.github/workflows')
    rescue
        puts '.github/workflows does not exist'
    ensure
        puts 'end'
    end
end

checkIfExists('timkinsman', 'octofile')
checkIfExists('timkinsman', 'topify')