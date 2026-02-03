Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'] || Rails.application.credentials.dig(:google, :client_id),
           ENV['GOOGLE_CLIENT_SECRET'] || Rails.application.credentials.dig(:google, :client_secret),
           {
             scope: 'email,profile',
             prompt: 'select_account'
             # Don't hardcode redirect_uri - let OmniAuth determine it automatically
           }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}