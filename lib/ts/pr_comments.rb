# frozen_string_literal: true

def pr_comments(pr)
    pr.map { |item| item.comments }
end