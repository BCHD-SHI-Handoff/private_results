class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :rememberable, :registerable, and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable,
    :validatable, :confirmable, :lockable, :timeoutable

  enum role: [ :admin, :staff ]

  validates_presence_of :email, :role

  # This method is called by devise to check if user can login.
  def active_for_authentication?
    # Check with super and then check if our user is active
    super and self.active?
  end

  # For details on the below methods, see:
  # https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation
  # and http://stackoverflow.com/a/25544155

  def password_match?
    password == password_confirmation && !password.blank?
  end

  def password_required?
     new_record? ? false : super
  end

  # new function to set the password without knowing the current password used in our confirmation controller. 
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # new function to provide access to protected method unless_confirmed
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end
end
