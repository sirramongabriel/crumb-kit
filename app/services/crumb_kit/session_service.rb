# frozen_string_literal: true

# app/services/crumb_kit/session_service.rb
class SessionService
  def initialize(user)
    @user = user
  end

  # Generates session data including JWT and refresh token
  def generate_session_data
    session = create_session_and_tokens
    { user: @user, jwt: session[:jwt], refresh_token: session[:refresh_token] }
  end

  # Sets the JWT and refresh token in cookies
  def set_cookies(jwt, refresh_token, cookies) # rubocop:disable Metrics/MethodLength
    cookies.signed[:jwt] = {
      value: jwt,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax # TODO: Conditionally set this based on the env
    }
    cookies.signed[:refresh_token] = {
      value: refresh_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  private

  # Creates a session and generates JWT and refresh tokens
  def create_session_and_tokens
    session = @user.sessions.create
    jwt = generate_jwt_token(session)
    refresh_token = generate_refresh_token(session)
    { jwt: jwt, refresh_token: refresh_token }
  end

  # Generates a JWT token for the user session
  def generate_jwt_token(session)
    session.generate_token
  end

  # Generates a refresh token for the user session
  def generate_refresh_token(session)
    session.generate_refresh_token
  end
end
