class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :provider, :uid, :nickname, :avatar, :lat, :lon

  validates :role, :presence => true

	before_save :check_for_nickname
	before_save :check_for_role

  # if no nickname supplied, default to name in email before '@'
  def check_for_nickname
    self.nickname = self.email.split('@')[0] if self.nickname.blank? && self.email.present?
  end

	# if no role is supplied, default to the basic user role
	def check_for_role
		self.role = ROLES[:user] if !self.role.present?
	end

  def self.no_admins
    where("role != ?", ROLES[:admin])
  end

  # use role inheritence
  # - a role with a larger number can do everything that smaller numbers can do
  ROLES = {:user => 0, :admin => 99}
  def role?(base_role)
    if base_role && ROLES.values.index(base_role)
      return base_role <= self.role
    end
    return false
  end
  
  def role_name
    ROLES.keys[ROLES.values.index(self.role)].to_s
  end
  

	##############################
	## omniauth methods
	##############################
	# get user credentials from omniauth
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(nickname:auth.info.nickname,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           avatar:auth.info.image,
                           password:Devise.friendly_token[0,20]
                           )
    end
    user
  end

	# if login fails with omniauth, sessions values are populated with
	# any data that is returned from omniauth
	# this helps load them into the new user registration url
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end


	# if user logged in with omniauth, password is not required
	def password_required?
		super && provider.blank?
	end


end
