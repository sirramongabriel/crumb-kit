# frozen_string_literal: true

# lib/crumb_kit/jwt.rb
require "jwt"

module Jwt
  def self.encode(payload, secret_key, algorithm = "HS256")
    JWT.encode(payload, secret_key, algorithm)
  end

  def self.decode(token, secret_key, algorithm = "HS256")
    JWT.decode(token, secret_key, algorithm)[0]
  end

  class VerificationError < StandardError; end
  class DecodeError < StandardError; end
end
