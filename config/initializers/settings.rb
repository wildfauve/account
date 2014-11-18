Setting.load(path:  "#{Rails.root}/config/settings",
             files:  ["default.yml", "environments/#{Rails.env}.yml"],
             local: true)