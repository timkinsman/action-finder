# frozen_string_literal: true

require_relative 'lib/dl_dataset'
require_relative 'lib/filter_dataset'
require_relative 'lib/find_actions'
require_relative 'lib/find_workflows'
require_relative 'lib/rank_actions'
require_relative 'lib/retrieve_actions_metadata'
require_relative 'lib/retrieve_commit_history'
require_relative 'lib/filter_commit_history'

dl_dataset(ARGV[2])
filter_dataset("#{ARGV[2]}/dataset.csv", "#{ARGV[2]}/dataset_filtered.csv")
find_workflows(ARGV[0], ARGV[1], "#{ARGV[2]}/dataset_filtered.csv", "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows")
find_actions(ARGV[2], "#{ARGV[2]}/actions_no_docker.csv")
rank_actions("#{ARGV[2]}/actions_no_docker.csv", "#{ARGV[2]}/actions_ranked_no_docker.csv")
retrieve_actions_metadata("#{ARGV[2]}/actions_ranked_no_docker.csv", "#{ARGV[2]}/actions_metadata_no_docker.csv")
retrieve_commit_history(ARGV[0], ARGV[1], "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows_commit_history")
filter_commit_history("#{ARGV[2]}/workflows_commit_history")
 