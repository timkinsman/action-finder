# frozen_string_literal: true

require_relative 'lib/dl_dataset'
require_relative 'lib/filter_dataset'
require_relative 'lib/find_workflows'
require_relative 'lib/find_actions'
require_relative 'lib/rank_actions'

dataset_filtered_path = "#{ARGV[2]}/dataset_filtered.csv"
actions_path = "#{ARGV[2]}/actions.csv"

# download dataset from reporeapers.github.io
dl_dataset(ARGV[2])

# filter dataset to repositories that scored 1 in either randomforest_org or randomforest_utl
filter_dataset("#{ARGV[2]}/dataset.csv", dataset_filtered_path)

# find which repositories exist and have workflow files
find_workflows(ARGV[0], ARGV[1], dataset_filtered_path, "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows")

# find which workflow files have github actions
find_actions(ARGV[2], actions_path)

# rank the github actions
rank_actions(actions_path, "#{ARGV[2]}/actions-ranked.csv")
