# frozen_string_literal: true

def pr_closed_at(pr)
    pr.map { |item| item.closed_at }
end