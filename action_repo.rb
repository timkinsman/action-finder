# frozen_string_literal: true

require_relative 'lib/dl_dataset'
require_relative 'lib/filter_dataset'
require_relative 'lib/find_actions'
require_relative 'lib/find_workflows'
require_relative 'lib/rank_actions'
require_relative 'lib/retrieve_actions_metadata'
require_relative 'lib/retrieve_commit_history'
require_relative 'lib/filter_commit_history'

# download dataset from reporeapers.github.io
# dl_dataset(ARGV[2])

# filter dataset to repositories that scored 1 in either randomforest_org or randomforest_utl
# filter_dataset("#{ARGV[2]}/dataset.csv", "#{ARGV[2]}/dataset_filtered.csv")

# find which repositories exist and have workflow files
# find_workflows(ARGV[0], ARGV[1], "#{ARGV[2]}/dataset_filtered.csv", "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows")

# find which workflow files have github actions
# find_actions(ARGV[2], "#{ARGV[2]}/actions.csv")

# rank the github actions
# rank_actions("#{ARGV[2]}/actions.csv", "#{ARGV[2]}/actions_ranked.csv")

# retrieve the actions metadata (categories, about, verified)
# retrieve_actions_metadata("#{ARGV[2]}/actions_ranked.csv", "#{ARGV[2]}/actions_metadata.csv")

#retrieve_commit_history(ARGV[0], ARGV[1], "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows_commit_history")
filter_commit_history("#{ARGV[2]}/workflows_commit_history")
