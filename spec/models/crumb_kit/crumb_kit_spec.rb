# frozen_string_literal: true

require "crumb_kit/models/user"

RSpec.describe CrumbKit::User, type: :model do # rubocop:disable Metrics/BlockLength
  subject do
    CrumbKit::User.new(first_name: "John", last_name: "Doe", username: "johndoe", email: "test@example.com",
                       password: "password")
  end

  describe "associations" do
    # These will likely fail unless you've also moved and set up Address, UserRole, and Role models
    # and their associations within your gem. For now, you might need to comment these out or adapt them.
    # it { should have_one(:address) }
    # it { should accept_nested_attributes_for(:address).allow_destroy(true) }
    # it { should have_many(:user_roles) }
    # it { should have_many(:roles).through(:user_roles) }
  end

  describe "validations" do
    it { should have_secure_password }
    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(50) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("test@example.com").for(:email) }
  end

  describe "is?" do
    let(:user) do
      CrumbKit::User.new(first_name: "John", last_name: "Doe", username: "johndoe", email: "test@example.com",
                         password: "password")
    end
    # You'll need to decide how you want to handle roles in your gem.
    # This example assumes you might have a 'roles' association.
    # For now, I'm commenting out the role setup as it depends on other models.
    # let(:attendee_role) { instance_double('CrumbKit::Role', name: 'attendee') }
    # let(:promoter_role) { instance_double('CrumbKit::Role', name: 'promoter') }

    before do
      # You'll need to adjust this based on how you're handling roles in your gem
      # user.roles << attendee_role
    end

    it "returns true if user has the role" do
      # Adjust this expectation based on your gem's implementation
      # expect(user.is?('attendee')).to be true
      pending "Implement role functionality in the gem and update this test"
    end

    it "returns false if user does not have the role" do
      # Adjust this expectation based on your gem's implementation
      # expect(user.is?('promoter')).to be false
      pending "Implement role functionality in the gem and update this test"
    end

    it "handles symbol input" do
      # Adjust this expectation based on your gem's implementation
      # expect(user.is?(:attendee)).to be true
      pending "Implement role functionality in the gem and update this test"
    end
  end
end
