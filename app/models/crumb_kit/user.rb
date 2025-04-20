# app/models/crumb_kit/user.rb
# frozen_string_literal: true

# Represents a user in the CrumbKit authentication system.
# Includes functionality for authentication, session handling,
# email normalization, and password reset.
class CrumbKit::User < ApplicationRecord
  has_secure_password

  # Updated before_save callbacks
  before_save :generate_full_name_slug

  has_many :sessions, dependent: :destroy

  # Modern Rails way to handle email normalization
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Ensure your email validation includes presence, uniqueness, AND format
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP } # <-- Add/Correct this line

  validates :first_name, :last_name, presence: true
  validates :password_digest, presence: true, on: :create

  def full_name
    "#{first_name.to_s.downcase.titleize} #{last_name.to_s.downcase.titleize}"
  end

  def generate_full_name_slug
    self.name_slug = "#{first_name.to_s.downcase}-#{last_name.to_s.downcase}"
  end

  def generate_password_reset_token
    return unless password_reset_token.blank?

    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.current
  end

  def password_reset_token_valid?
    password_reset_token.present? && password_reset_sent_at.present? && (password_reset_sent_at + 2.hours > Time.now.utc) # rubocop:disable Layout/LineLength
  end
end
