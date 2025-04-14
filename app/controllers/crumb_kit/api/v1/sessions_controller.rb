# frozen_string_literal: true

# app/controllers/crumb_kit/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionController::Cookies

  def create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    Rails.logger.debug "Received parameters: #{params[:session]}"

    if invalid_session_params?
      return render json: { error: 'Email and password are required' }, status: :unprocessable_entity
    end

    user = find_user_by_email(params[:session][:email])

    Rails.logger.debug "User found: #{user.inspect}"

    if user.nil?
      log_invalid_user(params[:session][:email])
      return render json: { error: 'Invalid credentials' }, status: :unauthorized
    end

    if user.authenticate(params[:session][:password])
      log_successful_authentication(user)

      # Generate session data and tokens using JwtService
      payload = { user_id: user.id }
      session_data = JwtService.encode(payload)

      # Create and store the session in the database
      Session.create!(
        user: user,
        token: session_data[:jwt],
        refresh_token: session_data[:refresh_token],
        expires_at: session_data[:expires_at]
      )

      SessionService.new(user).set_cookies(session_data[:jwt], session_data[:refresh_token], cookies)

      # Include expiration time (expires_at) and user data with roles in the response
      render json: {
        data: {
          jwt: session_data[:jwt],
          user: user,
          user_address: user.address,
          user_roles: user.user_roles
        }
      }, status: :ok
    else
      log_invalid_credentials(user)
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  rescue JWT::EncodeError => e
    log_error("JWT encoding error: #{e.message}")
    render json: { error: 'Internal server error' }, status: :internal_server_error
  rescue ActiveRecord::RecordInvalid => e
    log_error("Session creation error: #{e.message}")
    render json: { error: 'Internal server error' }, status: :internal_server_error
  rescue StandardError => e
    log_error("Unexpected error during login: #{e.message}")
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  def destroy
    if current_user
      terminate_current_session

      cookies.delete(:jwt, path: '/')
      cookies.delete(:refresh_token, path: '/')

      render json: { message: 'Logged out successfully' }, status: :ok
    else
      render json: { error: 'No active session found' }, status: :unprocessable_entity
    end
  end

  def refresh_token # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    refresh_token_cookie = cookies[:refresh_token]

    return render json: { error: 'Refresh token not found' }, status: :unauthorized if refresh_token_cookie.blank?

    session = Session.find_by(refresh_token: refresh_token_cookie)

    if session.nil? || session.send(:session_expired?, session)
      return render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
    end

    user = session.user
    payload = { user_id: user.id }
    new_session_data = JwtService.encode(payload)

    # Generate a new refresh token
    new_refresh_token = SecureRandom.uuid
    session.update(token: new_session_data[:jwt], expires_at: new_session_data[:expires_at],
                   refresh_token: new_refresh_token)

    # Set the new JWT and the new refresh token in cookies
    SessionService.new(user).set_cookies(new_session_data[:jwt], new_refresh_token, cookies)

    render json: {
      data: {
        jwt: new_session_data[:jwt],
        expires_at: new_session_data[:expires_at],
        user: user,
        user_address: user.address,
        user_roles: user.user_roles
      }
    }, status: :ok
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    render json: { error: 'Invalid refresh token' }, status: :unauthorized
  rescue JWT::EncodeError => e
    Rails.logger.error "JWT Encode Error Message: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  rescue StandardError => e
    Rails.logger.error "Error during refresh: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  def me # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    if current_user
      puts "User first_name: #{current_user.first_name}"
      user_data = {
        id: current_user.id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        username: current_user.username || nil,
        user_address: current_user.address || nil,
        user_roles: current_user.user_roles
      }
      render json: user_data, status: :ok
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def invalid_session_params?
    session_params[:email].blank? || session_params[:password].blank?
  end

  def find_user_by_email(email)
    User.find_by(email: email.strip.downcase)
  end

  def log_invalid_user(email)
    Rails.logger.debug "User not found with email: #{email}"
  end

  def log_successful_authentication(user)
    Rails.logger.debug "User authenticated successfully: #{user.email}"
  end

  def log_invalid_credentials(user)
    Rails.logger.debug "Invalid credentials for email: #{user&.email}"
  end

  def log_error(message)
    Rails.logger.error message
  end
end
