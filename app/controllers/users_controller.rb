class UsersController < ApplicationController
  def index
    @users = User.all

    render "/users"
  end
end