# app/controllers/crumb_kit/api/v1/passwords_controller.rb

class Api::V1::PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[create update]

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_reset_token
      user.update_columns(password_reset_sent_at: Time.now.utc)
      # UserMailer.with(user: user).password_reset.deliver_now
    end
    render json: { message: 'Email sent if user exists' }, status: :ok
  end

  def update
    token = params[:token]
    user = User.where('password_reset_token = ?', token).first

    return render json: { error: 'Invalid or expired password reset token.' }, status: :unauthorized if user.nil?

    unless user.password_reset_token_valid?
      return render json: { error: 'Invalid or expired password reset token.' }, status: :unauthorized
    end

    return render json: { errors: ['Password is required.'] }, status: :unprocessable_entity if params[:password].blank?

    if params[:password] != params[:password_confirmation]
      return render json: { errors: ['Password and confirmation do not match.'] }, status: :unprocessable_entity
    end

    user.password = params[:password]
    if user.save
      user.update_columns(password_reset_token: nil, password_reset_sent_at: nil)
      render json: { message: 'Password reset successful' }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError
    render json: { error: 'Password reset failed due to an internal error.' }, status: :internal_server_error
  end
end