Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins /^[a-z0-9\-_]+\.hyperlog\.dev/
    resource '/data_api/*', headers: :any, methods: %i[get post patch put]
  end
end
