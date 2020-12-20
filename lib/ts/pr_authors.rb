# frozen_string_literal: true

def pr_authors(pr)
    pr.map { |item| item.user.login }
end