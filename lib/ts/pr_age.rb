# frozen_string_literal: true

require 'octokit'

require_relative '../util/authenticate'
require_relative '../util/check_rate_limit'

def pr_age(token, spinner, repo, date)
    i = 0
    while true
        i = i + 1

        client = authenticate(token)
        check_rate_limit(client, 10, spinner) # 10 call buffer
    
        begin
            time = client.pull_request(repo, i).created_at
        rescue StandardError
            next
        end
        return ((date - DateTime.strptime(time.to_s, '%Y-%m-%d')).to_i / 30.4167).floor
    end
end
