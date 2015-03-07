class UsersController < ApplicationController
  respond_to :html, :js
  before_action :find_user, only: [:edit, :update, :destroy]


  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    @user  = User.create(user_params.merge({active: true, password: generated_password}))
    # RegistrationMailer.welcome(user, generated_password).deliver
    flash[:notice] = "Email sent to '#{@user.email}'."
  end

  def update
    @user.update_attributes(user_params)
  end

  def destroy
    @user.destroy()
  end

  def user_params
    params.require(:user).permit(:email, :role, :active)
  end

  def find_user
    @user = User.find(params[:id])
  end
end