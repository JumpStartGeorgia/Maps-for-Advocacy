class User < ActiveRecord::Base
	has_many :organization_users, :dependent => :destroy
	has_many :organizations, :through => :organization_users

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, 
      :provider, :uid, :nickname, :avatar, :organization_ids, 
      :lat, :lon, :district_id
  attr_accessor :lat_orig, :lon_orig
  
  validates :role, :presence => true

	before_save :check_for_nickname
	before_save :check_for_role

  include GeoRuby::SimpleFeatures

	after_find :populate_orig_coordinates
  before_save :assign_district

  ROLES = {:user => 0, :certification => 50, :organization_admin => 60, :site_admin => 75, :admin => 99}

	# have to check if lat/lon coordinates change on save and if so, update the district id
	def populate_orig_coordinates
		self.lat_orig = read_attribute(:lat)
		self.lon_orig = read_attribute(:lon)
	end

  # if the lat/lon has changed, update the district id
  def assign_district(override=false)
    if (self.lat_orig != self.lat || self.lon_orig != self.lon) || override
      if self.lat.nil? || self.lon.nil?
        self.district_id = nil
      else
        require 'geo_ruby/geojson'
        
        point = Point.from_lon_lat(self.lon, self.lat)
        
        districts = District.order('id')
        districts.each do |district|
          geo = Geometry.from_geojson(district.json)
          if geo.contains_point?(point)
            self.district_id = district.id
            break
          end
        end
      end
    end
    return nil
  end


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
      user = User.create(nickname: auth.info.nickname,
                           provider: auth.provider,
                           uid: auth.uid,
                           email: auth.info.email.present? ? auth.info.email : 'temp@temp.com',
                           avatar: auth.info.image,
                           password: Devise.friendly_token[0,20]
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



	##############################
	##############################
	##############################
  def self.for_evaluations(user_ids)
    select('id, nickname, avatar').where(:id => user_ids) if user_ids.present?
  end

  # get all users not in the list
  def self.not_in_list(user_id_list)
    where('id not in (?)', user_id_list)
    .order('nickname asc')
  end



end
