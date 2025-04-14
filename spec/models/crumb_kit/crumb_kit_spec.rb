# frozen_string_literal: true

RSpec.describe CrumbKit::User, type: :model do # rubocop:disable Metrics/BlockLength
  subject do
    described_class.new(
      first_name: 'John',
      last_name: 'Doe',
      username: 'johndoe',
      email: 'test@example.com',
      password: 'password'
    )
  end

  describe 'validations' do
    it { should have_secure_password }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    it { should validate_length_of(:username).is_at_least(3).is_at_most(50) }
    it { should validate_uniqueness_of(:username).case_insensitive }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('not-an-email').for(:email) }
  end

  describe '#full_name' do
    it 'returns the concatenated first and last name' do
      expect(subject.full_name).to eq('John Doe')
    end
  end

  describe '#generate_full_name_slug' do
    it 'returns the concatenated lowercased first and last name with hyphens instead of spaces' do
    end
  end
end
