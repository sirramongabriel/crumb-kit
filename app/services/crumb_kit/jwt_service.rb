# frozen_string_literal: true

# app/services/crumb_kit/jwt_service.rb
class JwtService
  ENCRYPTION_KEY = Rails.application.credentials.secret_key_base[0..31]

  # Encode the payload into a JWT token
  def self.encode(payload)
    payload[:exp] ||= 1.hour.from_now.utc.to_i
    encrypted_payload = encrypt_payload(payload)

    jwt_token = JWT.encode(encrypted_payload, Rails.application.credentials.secret_key_base, "HS256")

    { jwt: jwt_token, expires_at: payload[:exp] }
  end

  # Decode the JWT token and retrieve the payload
  def self.decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
    encrypted_payload = decoded.first

    decrypt_payload(encrypted_payload)
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT decode error: #{e.message}")
    nil
  end

  def self.encrypt_payload(payload)
    cipher = OpenSSL::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = ENCRYPTION_KEY
    iv = cipher.random_iv

    # Encrypt payload and ensure it's UTF-8 encoded
    encrypted = cipher.update(payload.to_json) + cipher.final

    # Base64 encode both the encrypted data and IV to safely store them as strings
    {
      iv: [iv].pack("m0"), # Base64 encode the IV
      encrypted_data: [encrypted].pack("m0") # Base64 encode the encrypted data
    }
  end

  def self.decrypt_payload(encrypted_payload)
    cipher = OpenSSL::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = ENCRYPTION_KEY

    # Base64 decode the IV and encrypted data
    cipher.iv = encrypted_payload["iv"].unpack1("m0") # Decode the IV
    encrypted_data = encrypted_payload["encrypted_data"].unpack1("m0") # Decode the encrypted data

    decrypted = cipher.update(encrypted_data) + cipher.final
    JSON.parse(decrypted)
  end
end
