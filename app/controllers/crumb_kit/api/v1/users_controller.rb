# frozen_string_literal: true

# app/controllers/crumb_kit/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  before_action :allow_unauthenticated_access, only: %i[create me]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all
    render json: {
      status: {
        code: 20,
        message: 'Users'
      },
      data: {
        user: @user
      }
    }
  end

  def show
    render json: {
      status: {
        code: 200,
        message: 'User Page'
      },
      data: {
        user: @user
      }
    }
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @user = User.new(user_params)

    if @user.save
      session = @user.sessions.create
      jwt = session.generate_token
      refresh_token = session.generate_refresh_token

      # Instantiate SessionService
      session_service = SessionService.new(@user)
      # Use the service to set registration cookies
      session_service.set_registration_cookies(jwt, refresh_token, cookies)

      render json: {
        status: {
          code: 201,
          message: 'User registered successfully'
        },
        data: {
          jwt: jwt,
          user: @user
        }
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue JWT::EncodeError => e
    Rails.logger.error "JWT encoding error: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Session creation error: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  rescue StandardError => e
    Rails.logger.error "Unexpected error during user creation: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  def update # rubocop:disable Metrics/MethodLength
    if @user.update(user_params)
      render json: {
        status: {
          code: 200,
          message: 'User updated successfully'
        },
        data: {
          user: @user
        }
      }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password
    )
  end
end
