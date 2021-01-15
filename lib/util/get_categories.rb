# frozen_string_literal: true

require 'csv'
require 'tty-spinner'
require 'json'

def get_categories
    CSV.open('data/categories_used.csv', 'w') do |write|
        write << ["repository", "actions", "Utilities", "Dependency management", "Continuous integration",
            "Code quality", "Code review", "Publishing", "Container CI", "Security",
            "Project management", "Testing", "Deployment", "Chat", "Open Source management",
            "IDEs", "Localization", "Mobile CI", "Mobile", "Desktop tools",
            "Monitoring", "Reporting", "Community"
        ]
        CSV.foreach('data/actions_used.csv', headers:true) do |row|
            arrRow = [row[0], row[1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

            actions = JSON.parse(row[1])
            actions.each do |action|
                CSV.foreach('data/actions_final.csv', headers:true) do |csv|
                    if action == csv[0]
                        #regex switch case for categoies and place a +1 in each cateogory for repo
                        arrRow[2] = arrRow[2] + 1 if csv[1] =~ /Utilities/
                        arrRow[3] = arrRow[3] + 1 if csv[1] =~ /Dependency management/
                        arrRow[4] = arrRow[4] + 1 if csv[1] =~ /Continuous integration/
                        arrRow[5] = arrRow[5] + 1 if csv[1] =~ /Code quality/
                        arrRow[6] = arrRow[6] + 1 if csv[1] =~ /Code review/
                        arrRow[7] = arrRow[7] + 1 if csv[1] =~ /Publishing/
                        arrRow[8] = arrRow[8] + 1 if csv[1] =~ /Container CI/
                        arrRow[9] = arrRow[9] + 1 if csv[1] =~ /Security/
                        arrRow[10] = arrRow[10] + 1 if csv[1] =~ /Project management/
                        arrRow[11] = arrRow[11] + 1 if csv[1] =~ /Testing/
                        arrRow[12] = arrRow[12] + 1 if csv[1] =~ /Deployment/
                        arrRow[13] = arrRow[13] + 1 if csv[1] =~ /Chat/
                        arrRow[14] = arrRow[14] + 1 if csv[1] =~ /Open Source management/
                        arrRow[15] = arrRow[15] + 1 if csv[1] =~ /IDEs/
                        arrRow[16] = arrRow[16] + 1 if csv[1] =~ /Localization/
                        arrRow[17] = arrRow[17] + 1 if csv[1] =~ /Mobile CI/
                        arrRow[18] = arrRow[18] + 1 if csv[1] =~ /Mobile/
                        arrRow[19] = arrRow[19] + 1 if csv[1] =~ /Desktop tools/
                        arrRow[20] = arrRow[20] + 1 if csv[1] =~ /Monitoring/
                        arrRow[21] = arrRow[21] + 1 if csv[1] =~ /Reporting/
                        arrRow[22] = arrRow[22] + 1 if csv[1] =~ /Community/
                    end
                end
            end
            write << arrRow
        end
    end
end
