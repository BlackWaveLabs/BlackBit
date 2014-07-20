bundle exec rails s -e production -d
bundle exec sidekiq -L log/sidekiq.log -q default -e production -d
