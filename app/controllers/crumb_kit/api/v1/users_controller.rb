# frozen_string_literal: true

# app/controllers/crumb_kit/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :allow_unauthenticated_access, only: %i[create me]
  before_action :set_user, only: %i[show update destroy]

  def index # rubocop:disable Metrics/MethodLength
    @users = User.all
    render json: {
      status: {
        code: 20,
        message: 'Users'
      },
      data: {
        user: @user,
        user_address: @user.address,
        user_roles: @user.user_roles
      }
    }
  end

  def show # rubocop:disable Metrics/MethodLength
    render json: {
      status: {
        code: 200,
        message: 'User Page'
      },
      data: {
        user: @user,
        user_address: @user.address,
        user_roles: @user.user_roles
      }
    }
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @user = User.new(user_params)

    if @user.save
      handle_user_roles
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
          user: @user,
          user_address: @user.address,
          user_roles: @user.user_roles
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
          user: @user,
          user_address: @user.address,
          user_roles: @user.user_roles
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

  def handle_user_roles # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    user_roles_attributes = params[:user][:user_roles_attributes]
    return unless user_roles_attributes.present?

    user_roles_attributes.each do |role_data|
      role_id = role_data[:role_id]

      role = Role.find_by(id: role_id)
      unless role
        Rails.logger.warn "Role with ID #{role_id} not found."
        @user.errors.add(:base, "Error: Role with ID '#{role_id}' not found.")
        next
      end

      user_role = @user.user_roles.build(role_id: role.id)
      unless user_role.save
        Rails.logger.error "Error saving user role: #{user_role.errors.full_messages.join(", ")}"
        @user.errors.add(:base, 'Error assigning role.')
      end
    end
  end

  def role_selection_is_mandatory?
    # Role selection is mandatory
    true
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params # rubocop:disable Metrics/MethodLength
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :profile_picture,
      :rating,
      :username,
      address_attributes: %i[
        street
        city
        state
        zip
      ],
      user_roles_attributes: %i[
        role_id
      ]
    )
  end
end
