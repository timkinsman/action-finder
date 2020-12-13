# frozen_string_literal: true

require 'csv'
require 'tty-spinner'
require 'json'

def get_repository
    count = 0

    CSV.foreach('data/actions_used.csv', headers:true) do |row|
        #actions = JSON.parse(row[1]).reject {|w| w == "actions/checkout" or w =~ /setup-/}
        #actions = JSON.parse(row[1]).reject {|w| w == "actions/checkout"}
        actions = JSON.parse(row[1])
        if actions.length == 1
            print row
            count = count + 1
        end
    end

    print count
end

get_repository