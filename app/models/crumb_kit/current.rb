# frozen_string_literal: true

# app/models/crumb_kit/current.rb
class CrumbKit::Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
end
