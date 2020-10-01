# frozen_string_literal: true

require_relative 'lib/reporeaper/download_dataset'
require_relative 'lib/reporeaper/filter_dataset'

require_relative 'lib/workflows/retrieve_workflow_snapshot'
require_relative 'lib/workflows/retrieve_workflow_commits'

require_relative 'lib/actions/extract_actions_workflow_snapshot'
require_relative 'lib/actions/count_actions_workflow_snapshot'
require_relative 'lib/actions/count_actions_workflow_commits'
require_relative 'lib/actions/web_scrape_actions_metadata'

require_relative 'lib/issues/search_issues'
require_relative 'lib/issues/web_scrape_issues'

#download_dataset('data/dataset.csv')
#filter_dataset('data/dataset.csv', 'data/dataset_filtered.csv')

#retrieve_workflow_snapshot(ARGV[0], ARGV[1], 'data/dataset_filtered.csv', 'data/workflows.csv', 'data/workflows_snapshot')
#retrieve_workflow_commits(ARGV[0], ARGV[1], 'data/workflows.csv', 'data/workflows_commits')

#extract_actions_workflow_snapshot('data/actions.csv', 'data/workflows_snapshot')
#count_actions_workflow_snapshot('data/actions.csv', data/actions_snapshot.csv')
#count_actions_workflow_commits('data/actions_commits.csv', "data/workflows_commits")
#web_scrape_actions_metadata('data/actions_commits.csv', 'actions_final.csv')

#search_issues(ARGV[0], ARGV[1], 'data/actions_final.csv', 'data/actions.csv')
#web_scrape_issues("#{ARGV[2]}/actions_ranked.csv", "#{ARGV[2]}/actions_metadata.csv")
