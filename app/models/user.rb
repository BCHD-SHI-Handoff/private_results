class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :rememberable, :registerable, and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable,
    :validatable, :confirmable, :lockable, :timeoutable
end
