# frozen_string_literal: true

require_relative '../util/authenticate'
require_relative '../util/check_rate_limit'

def pr_commits(token, spinner, repo, pr)
    tmp = []
    pr.map do |item|
        client = authenticate(token)
        check_rate_limit(client, 10, spinner) # 10 call buffer

        client.auto_paginate = true

        tmp << client.pull_request_commits(repo, item.number).count
    end
    tmp
end