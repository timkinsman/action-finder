# frozen_string_literal: true

require_relative 'lib/get_dataset'
require_relative 'lib/get_workflows'
require_relative 'lib/get_actions'
require_relative 'lib/web_scrape_actions'
require_relative 'lib/get_issues'
require_relative 'lib/web_scrape_issues'
require_relative 'lib/get_adoption_date'
require_relative 'lib/time_series'

get_dataset

get_workflows ARGV[0], ARGV[1]

get_actions
web_scrape_actions

get_issues ARGV[0], ARGV[1]
web_scrape_issues

get_adoption_date
time_series ARGV[0], ARGV[1]
