class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :rememberable, :registerable, and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable,
    :validatable, :confirmable, :lockable, :timeoutable

  def admin?
    self.role == 'admin'
  end

  # XXX Dummy until we have real role attribute
  def role
    'admin'
  end

  # XXX Dummy until we have real active attribute
  def active?
    true
  end
end
