Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials.dig(:google, :client_id),
           Rails.application.credentials.dig(:google, :client_secret),
           {
             scope: 'email,profile',
             prompt: 'select_account',
             redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback'
           }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}