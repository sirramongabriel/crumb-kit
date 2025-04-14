# frozen_string_literal: true

# CrumbKit::Session is the model that handles user session creation and management.
# It generates tokens for authenticating users and ensures that session expiration is managed properly.
#
# Example:
#   session = CrumbKit::Session.create(user: user)
#   session.token      # Access the session token
#   session.expires_at # Check the session expiration
class CrumbKit::Session < ApplicationRecord
  belongs_to :user

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  before_validation :generate_refresh_token, on: :create

  # Generates a JWT token for the session, with an expiration time and user ID.
  # @raise [StandardError] if token generation fails
  def generate_token
    payload = {
      exp: 1.hour.from_now.to_i, # Expiration in 1 hour
      iat: Time.now.utc.to_i,    # Issued at the current time in UTC
      user_id: user.id           # Include user ID in the payload
    }

    self.token = JwtService.encode(payload)
  rescue StandardError => e
    Rails.logger.error "Error generating session token: #{e.message}"
    errors.add(:base, 'Failed to generate session token.')
    throw :abort # Prevent session creation
  end

  # Generates a unique refresh token for the session.
  # @raise [StandardError] if refresh token generation fails
  def generate_refresh_token
    self.refresh_token = SecureRandom.uuid
  rescue StandardError => e
    Rails.logger.error "Error generating refresh token: #{e.message}"
    errors.add(:base, 'Failed to generate refresh token.')
    throw :abort # Prevent session creation
  end

  private

  # Sets the expiration timestamp for the session.
  # @raise [StandardError] if expiration setting fails
  def set_expiration
    self.expires_at = 1.hour.from_now
  rescue StandardError => e
    Rails.logger.error "Error setting session expiration: #{e.message}"
    errors.add(:base, 'Failed to set session expiration.')
    throw :abort # Prevent session creation
  end
end
