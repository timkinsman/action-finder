# frozen_string_literal: true

require_relative 'lib/dl-dataset'
require_relative 'lib/filter-dataset'
require_relative 'lib/find-workflows'
require_relative 'lib/find-actions'
require_relative 'lib/rank-actions'

dataset_filtered_path = "#{ARGV[2]}/dataset_filtered.csv"
actions_path = "#{ARGV[2]}/actions.csv"

dl_dataset(ARGV[2]) #download dataset from reporeapers.github.io
filter_dataset("#{ARGV[2]}/dataset.csv", dataset_filtered_path) #filter dataset to repositories that scored 1 in either randomforest_org or randomforest_utl
find_workflows(ARGV[0], ARGV[1], dataset_filtered_path, "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows") #find which repositories exist and have workflow files
find_actions(ARGV[2], actions_path) #find which workflow files have github actions
rank_actions(ARGV[2], actions_path, "#{ARGV[2]}/actions-ranked.csv") #rank the github actions
