# app/models/crumb_kit/session.rb
class Session < ApplicationRecord
  include Authentication
  belongs_to :user

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  before_validation :generate_refresh_token, on: :create

  def generate_token
    payload = {
      exp: 1.hour.from_now.to_i, # Expiration in 1hr
      iat: Time.now.utc.to_i,    # Issued at current time UTC
      user_id: user.id           # Add user_id for decoding purposes
    }

    self.token = JwtService.encode(payload)
  rescue StandardError => e
    Rails.logger.error "Error generating session token: #{e.message}"
    errors.add(:base, 'Failed to generate session token.')
    throw :abort # No session created
  end

  def generate_refresh_token
    self.refresh_token = SecureRandom.uuid
  rescue StandardError => e
    Rails.logger.error "Error generating refresh token: #{e.message}"
    errors.add(:base, 'Failed to generate refresh token.')
    throw :abort # No session created
  end

  private

  def set_expiration
    self.expires_at = 1.hour.from_now
  rescue StandardError => e
    Rails.logger.error "Error setting session expiration: #{e.message}"
    errors.add(:base, 'Failed to set session expiration.')
    throw :abort # No session created
  end
end