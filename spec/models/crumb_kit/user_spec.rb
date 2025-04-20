# spec/models/crumb_kit/user_spec.rb
require 'spec_helper'

RSpec.describe CrumbKit::User, type: :model do
  subject(:user) do
    described_class.new(
      email: 'TEST@Email.COM',
      first_name: 'John',
      last_name: 'Doe',
      password: 'securepassword',
      password_confirmation: 'securepassword'
    )
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'generates a slug before saving' do
      user.save!
      expect(user.name_slug).to eq('john-doe')
    end
  end

  describe '#full_name' do
    it 'returns the full name in title case' do
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#generate_password_reset_token' do
    it 'does not overwrite an existing token' do
      user.password_reset_token = 'existingtoken'
      user.password_reset_sent_at = 1.hour.ago
      existing_token = user.password_reset_token
      user.generate_password_reset_token
      expect(user.password_reset_token).to eq(existing_token)
    end
  end

  describe '#password_reset_token_valid?' do
    it 'returns true if token exists and is within 2 hours' do
      user.password_reset_token = 'token'
      user.password_reset_sent_at = 1.hour.ago
      expect(user.password_reset_token_valid?).to be true
    end

    it 'returns false if token is missing' do
      expect(user.password_reset_token_valid?).to be false
    end

    it 'returns false if token is expired' do
      user.password_reset_token = 'token'
      user.password_reset_sent_at = 3.hours.ago
      expect(user.password_reset_token_valid?).to be false
    end
  end
end
