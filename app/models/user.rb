class User < ActiveRecord::Base
  validates :username, :presence => true, :uniqueness => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  has_many :authentications, :dependent => :destroy

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

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

  def apply_omniauth(omniauth)
    if (omniauth['info'] && omniauth['info']['email'])
      self.email = omniauth['info']['email'] if email.blank?
    end
    if (omniauth['info'] && omniauth['info']['nickname'])
      self.username = omniauth['info']['nickname'] if username.blank?
    else
      self.username = derive_username if username.blank?
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def derive_username
    split_email = self.email.split(/@/)
    username_taken = User.where(:username => split_email[0]).first
    unless username_taken
      split_email[0]
    else
      nil
    end
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

end
