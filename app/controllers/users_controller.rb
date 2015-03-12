class UsersController < ApplicationController
  use_growlyflash
  respond_to :html, :js
  before_action :find_user, only: [:edit, :update, :destroy, :send_reset_password]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    @user = User.create(user_params.merge({active: true, password: generated_password}))
    # RegistrationMailer.welcome(user, generated_password).deliver
    flash[:success] = "Email sent to '#{@user.email}'"
  end

  def update
    if !@user.update_attributes(user_params)
      flash[:error] = "Failed to update '#{@user.email}'"
    else
      if user_params["email"] || user_params["role"]
        flash[:success] = "Successfully updated '#{@user.email}'"
      elsif user_params["active"]
        action = user_params["active"] == 'true' ? "activated" : "deactivated"
        flash[:success] = "Successfully #{action} '#{@user.email}'"
      end
    end
  end

  def destroy
    if !@user.destroy()
      flash[:error] = "Failed to delete '#{@user.email}'"
    else
      flash[:success] = "'#{@user.email}' has been removed"
    end
  end

  def send_reset_password
    if !@user.send_reset_password_instructions
      flash[:error] = "Failed to send reset password instructions for '#{@user.email}'"
    else
      flash[:success] = "Reset password instructions send to '#{@user.email}'"
    end
    render nothing: true
  end

  def user_params
    params.require(:user).permit(:email, :role, :active)
  end

  def find_user
    @user = User.find(params[:id])
  end
end