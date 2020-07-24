require_relative 'lib/dl-workflows'
require_relative 'lib/filter-predicted'
require_relative 'lib/find-workflows'

filter_predicted('bata/dataset.csv', 'bata/dataset-filtered.csv')
find_workflows('timkinsman', ARGV[1], ARGV[2], ARGV[3])
dl_workflows('timkinsman', '', 'test.csv', 'workflows')