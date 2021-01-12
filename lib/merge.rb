require 'csv'

def merge
    CSV.open("data/TIME_SERIES_FINAL_FINAL.csv", 'w') do |csv|
        csv << [
            "owner",
            "repo",
            "action",
            "month_start",
            "month_end",
            "time",
            "intervention",
            "time_after_intervention",
            "merged",
            "nonmerged",
            "comments_merged",
            "comments_nonmerged",
            "close_time_merged",
            "close_time_nonmerged",
            "commits_merged",
            "commits_nonmerged",
            "lang",
            "total_number_pr_authors",
            "commits",
            "opened",
            "age_at_bot",
            "name",
            "index",
            "bot_comments",
            "action_primary_category",
            "action_secondary_category",
            "total_number_issues"]

        tmp = []

        CSV.foreach('data/TIME_SERIES_FINAL_ISSUES.csv', headers: true) do |final|
            found = false

            if tmp.empty? || final[21] != tmp[21]
                CSV.foreach('data/PR_AUTHORS.csv', headers: true) do |issues|
                    tmp = final
                    if issues[21] == final[21]
                        found = true
                        tmp[17] = issues[17]
                        break
                    end
                end
            else
                iss = tmp[17]
                tmp = final
                final[17] = iss
                found = true
            end

            if found != false && tmp[17] != ''
                csv << tmp
            end
        end
    end
end

merge