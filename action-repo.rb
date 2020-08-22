# frozen_string_literal: true

require_relative 'lib/dl-dataset'
require_relative 'lib/dl-workflows'
require_relative 'lib/filter-predicted'
require_relative 'lib/find-actions'
require_relative 'lib/find-workflows'
require_relative 'lib/rank-actions'

#dl_dataset(ARGV[2])
#filter_predicted("#{ARGV[2]}/dataset.csv", "#{ARGV[2]}/dataset-f.csv")
#find_workflows(ARGV[0], ARGV[1], "#{ARGV[2]}/dataset-f.csv", "#{ARGV[2]}/workflows.csv")
#dl_workflows(ARGV[0], ARGV[1], "#{ARGV[2]}/workflows.csv", "#{ARGV[2]}/workflows")
find_actions(ARGV[2], "#{ARGV[2]}/actions.csv")
rank_actions(ARGV[2], "#{ARGV[2]}/actions.csv", "#{ARGV[2]}/actions-r.csv")