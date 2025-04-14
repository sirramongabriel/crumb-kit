# lib/crumb_kit/jwt.rb
# frozen_string_literal: true

# Jwt module provides utility methods for encoding and decoding JSON Web Tokens (JWT).
# It uses the `jwt` gem for encoding and decoding the tokens and offers basic error handling.
#
# Example:
#   payload = { user_id: 123 }
#   secret_key = 'your-secret-key'
#   token = Jwt.encode(payload, secret_key)
#   decoded_payload = Jwt.decode(token, secret_key)
#
# @note The Jwt module relies on the `jwt` gem to encode and decode JWT tokens.
module Jwt
  # Encodes a payload into a JWT token.
  # @param payload [Hash] the data to encode in the token.
  # @param secret_key [String] the secret key used for signing the token.
  # @param algorithm [String] the signing algorithm (default: 'HS256').
  # @return [String] the encoded JWT token.
  def self.encode(payload, secret_key, algorithm = 'HS256')
    JWT.encode(payload, secret_key, algorithm)
  rescue StandardError => e
    Rails.logger.error "Error encoding JWT: #{e.message}"
    raise VerificationError, 'Failed to encode JWT token'
  end

  # Decodes a JWT token back into a payload.
  # @param token [String] the JWT token to decode.
  # @param secret_key [String] the secret key used to verify the token.
  # @param algorithm [String] the algorithm used to verify the token (default: 'HS256').
  # @return [Hash] the decoded payload.
  def self.decode(token, secret_key, algorithm = 'HS256')
    JWT.decode(token, secret_key, true, { algorithm: algorithm })[0]
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT decode error: #{e.message}"
    raise DecodeError, 'Failed to decode JWT token'
  rescue StandardError => e
    Rails.logger.error "Error decoding JWT: #{e.message}"
    raise DecodeError, 'Failed to decode JWT token'
  end

  # Error raised when token verification fails.
  class VerificationError < StandardError; end

  # Error raised when decoding the token fails.
  class DecodeError < StandardError; end
end
