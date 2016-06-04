require 'active_support'
require 'active_support/core_ext'

Time.zone = "Saskatchewan"
env :PATH, '/usr/local/bin:/usr/bin:/bin'

job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
job_type :script_without_bundler, "cd :path && RAILS_ENV=:environment :task :output"
job_type :runner, "cd :path && RAILS_ENV=:environment bundle exec rails runner :task :output"

# Backup the database and send to Amazon S3.
# every 1.day, at: Time.zone.parse('12:05 am').utc do
#   script_without_bundler "backup perform -t peak --config_file config/backup.rb && curl https://nosnch.in/a8d2f0ecd5"
# end

every :reboot do
  script_without_bundler "/usr/bin/env bin/delayed_job start"
end

every 1.day, at: Time.zone.parse('5:00 am').utc do
  rake "sitemap:refresh"
end