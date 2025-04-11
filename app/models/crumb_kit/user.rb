# app/models/crumb_kit/user.rb
class User < ApplicationRecord
  has_secure_password
  before_save :generate_full_name_slug, :sanitize_email

  has_one :address, as: :addressable
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :sessions, dependent: :destroy
  normalizes :email, with: ->(email) { email.strip.downcase }

  accepts_nested_attributes_for :address, allow_destroy: true
  accepts_nested_attributes_for :user_roles, reject_if: :all_blank, allow_destroy: true

  has_many :comments, as: :commentable # retaining comments from former users may provide value
  has_many :media_attachments, as: :attachable
  has_many :events
  has_many :owned_venues, class_name: 'Venue', foreign_key: 'user_id'
  has_many :reservations

  # Reviews written by the user about other users
  has_many :written_reviews, as: :reviewable, class_name: 'Review', foreign_key: :reviewer_id
  # Reviews received by the user from other users
  has_many :received_reviews, as: :reviewable, class_name: 'Review', foreign_key: :reviewee_id
  # All reviews associated with the user (polymorphic)
  has_many :reviews, as: :reviewable

  validates :first_name, :last_name, :email, presence: true
  validates :password_digest, presence: true, on: :create # Only validate on create
  validates :email, uniqueness: { case_sensitive: false }
  validates :username, length: { minimum: 3, maximum: 50 }

  scope :given, -> { where(reviewable_type: 'given') }
  scope :received, -> { where(reviewable_type: 'received') }

  def generate_full_name_slug
    self.name_slug = "#{first_name.downcase}-#{last_name.downcase}"
  end

  def generate_password_reset_token
    return unless password_reset_token.blank?

    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.now.utc
  end

  def is?(role_name)
    roles.exists?(name: role_name)
  end

  def venue_owner?
    owned_venues.exists?
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