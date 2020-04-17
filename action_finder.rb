# frozen_string_literal: true

require 'octokit'

def check_if_exists(owner, repo)
  pp Octokit.contents("#{owner}/#{repo}", path: '.github/workflows')
rescue StandardError
  puts ".github/workflows does not exist in #{owner}/#{repo}"
end

check_if_exists('timkinsman', 'octofile')
check_if_exists('timkinsman', 'topify')
