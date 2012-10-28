class User < ActiveRecord::Base
  validates :username, :presence => true, :uniqueness => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable, :registerable,
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  attr_accessor :login
  attr_accessible :email, :password, :password_confirmation, :username, :login, :remember_me

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  #def update_with_password(params={})
  #  if params[:password].blank?
  #    params.delete(:password)
  #    params.delete(:password_confirmation) if params[:password_confirmation].blank?
  #  end
  #  update_attributes(params)
  #end
  #
  #def password_required?
  #  (authentications.empty? || !password.blank?) && super
  #end

end
