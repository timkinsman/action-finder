# frozen_string_literal: true

def pr_created_at(pr)
    pr.map { |item| item.created_at }
end