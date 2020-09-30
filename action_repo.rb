# frozen_string_literal: true

require_relative 'lib/dl_dataset'
require_relative 'lib/filter_dataset'
require_relative 'lib/filter_workflow_commits'
require_relative 'lib/find_actions'
require_relative 'lib/find_workflows'
require_relative 'lib/rank_actions'
require_relative 'lib/retrieve_actions_metadata'
require_relative 'lib/retrieve_workflow_commits'

#dl_dataset(ARGV[2])
#filter_dataset(ARGV[2])
#find_workflows(ARGV[0], ARGV[1], "#{ARGV[2]}/dataset_filtered.csv", "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows")
#find_actions(ARGV[2], "#{ARGV[2]}/actions-testing.csv")
#rank_actions("#{ARGV[2]}/actions.csv", "#{ARGV[2]}/actions_ranked.csv")
#retrieve_workflow_commits(ARGV[0], ARGV[1], "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows_commits")
#filter_workflow_commits("#{ARGV[2]}/commits_filtered", ARGV[2])
#retrieve_actions_metadata("#{ARGV[2]}/actions_ranked.csv", "#{ARGV[2]}/actions_metadata.csv")
