# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  google_credentials = Rails.application.credentials.google || {}
  client_id = ENV['GOOGLE_CLIENT_ID'].presence || google_credentials[:client_id]
  client_secret = ENV['GOOGLE_CLIENT_SECRET'].presence || google_credentials[:client_secret]

  if client_id.present? && client_secret.present?
    provider :google_oauth2, client_id, client_secret, {
      scope: 'email, profile', # Grants access to the user's email and profile information.
      prompt: 'select_account', # Allows users to choose the account they want to log in with.
      image_aspect_ratio: 'square', # Ensures the profile picture is a square.
      image_size: 50 # Sets the profile picture size to 50x50 pixels.
    }
  else
    Rails.logger.warn('Google OAuth is not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET to enable login.')
  end
end
