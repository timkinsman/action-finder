# frozen_string_literal: true

def pr_time_to(created_at, closed_at)
    tmp = []
    created_at.select.each_with_index do |item, index|
        tmp << ((DateTime.strptime(closed_at[index].to_s, '%Y-%m-%d') - DateTime.strptime(item.to_s, '%Y-%m-%d')).to_i * 24).round
    end
    tmp
end
