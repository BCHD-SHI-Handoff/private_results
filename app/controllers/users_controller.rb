class UsersController < ApplicationController
  use_growlyflash
  respond_to :html, :js
  before_action :find_user, only: [:edit, :update, :destroy, :send_reset_password]
  before_filter :verify_is_admin

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge({active: true}))

    respond_to do |format|
      if @user.save
        flash[:success] = "Email sent to '#{@user.email}'"
        format.js
      else
        format.js { render 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        if user_params["email"] || user_params["role"]
          flash[:success] = "Successfully updated '#{@user.email}'"
        elsif user_params["active"]
          action = user_params["active"] == 'true' ? "activated" : "deactivated"
          flash[:success] = "Successfully #{action} '#{@user.email}'"
        end
        format.js
      else
        format.js { render 'edit' }
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

  private

  def user_params
    params.require(:user).permit(:email, :role, :active)
  end

  def find_user
    @user = User.find(params[:id])
  end
end