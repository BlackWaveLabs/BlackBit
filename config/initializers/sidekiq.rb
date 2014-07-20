sidekiq_url = "localhost:6379"

#Sidekiq.configure_server do |config|
#  config.redis = { :url => 'redis://localhost:6379', :namespace => 'excoin' }
#end

#Sidekiq.configure_client do |config|
#  config.redis = { :url => 'redis://localhost:6379', :namespace => 'excoin' }
#end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
  end
end


