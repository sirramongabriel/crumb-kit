# frozen_string_literal: true

# lib/crumb_kit/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  private

  # Handles the case where authentication is required but not provided
  def request_authentication_error
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  # Ensures authentication is required unless skipped via `allow_unauthenticated_access`
  def require_authentication
    # Skip authentication for actions defined as allowed
    return if self.class.unauthenticated_allowed_actions&.include?(action_name.to_sym)

    # Proceed with session management or raise error
    resume_session || request_authentication_error
  end

  # Find session by token (either JWT from cookie or session token from header)
  def find_session_by_any_token(token)
    Session.find_by(token: token)
  end

  # Start a new session for the user
  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
  end

  # Resume an existing session if valid
  def resume_session
    token = cookies.signed[:jwt] # Try to get token from cookie first

    token ||= extract_token_from_request

    return nil unless token

    session = find_session_by_any_token(token)
    return nil unless session

    # Validate the session
    if session_expired?(session)
      request_authentication_error # Handle expired sessions
      return nil
    end

    # Update session and assign to current_user
    update_session(session)
  end

  # Extract token from Authorization header
  def extract_token_from_request
    request.headers["Authorization"]&.split(" ")&.last
  end

  # Check if the session has expired
  def session_expired?(session)
    session.expires_at.nil? || session.expires_at <= Time.current.utc
  end

  # Update session timestamp
  def update_session(session)
    session.update!(last_accessed_at: Time.current)
  end

  # Terminate the current session
  def terminate_current_session
    token = cookies.signed[:jwt] || extract_token_from_request
    return unless token

    session = find_session_by_any_token(token)
    session&.destroy
  end
end
