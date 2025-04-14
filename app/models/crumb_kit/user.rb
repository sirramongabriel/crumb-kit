# app/models/crumb_kit/user.rb
# frozen_string_literal: true

# Represents a user in the CrumbLit authentication system.
# Includes functionality for authentication, session handling,
# email normalization, and password reset.
class CrumbLit::User < ApplicationRecord
  has_secure_password

  before_save :generate_full_name, :generate_full_name_slug, :sanitize_email

  has_many :sessions, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :first_name, :last_name, :email, presence: true
  validates :password_digest, presence: true, on: :create
  validates :email, uniqueness: { case_sensitive: false }
  validates :username, length: { minimum: 3, maximum: 50 }

  def generate_full_name
    @full_name = "#{first_name.downcase.titleize} #{last_name.downcase.titleize}"
  end

  def generate_full_name_slug
    self.name_slug = "#{first_name.downcase}-#{last_name.downcase}"
  end

  def generate_password_reset_token
    return unless password_reset_token.blank?

    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.now.utc
  end

  def password_reset_token_valid?
    if password_reset_sent_at.present?
      expiry_time = password_reset_sent_at + 2.hours
      now_utc = Time.now.utc
      expiry_time > now_utc
    else
      false
    end
  end

  def sanitize_email
    self.email = email.downcase if email.present?
  end
end
