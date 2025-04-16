ActsAsTenant.configure do |config|
  # config.require_tenant = false # true

  # Customize the query for loading the tenant in background jobs
  # config.job_scope = ->{ all }

  config.require_tenant = false
end