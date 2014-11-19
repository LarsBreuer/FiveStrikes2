class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  before_save :ensure_authentication_token

  has_many :friendship
  has_many :friend, 
           :through => :friendship,
           :conditions => "status = 'accepted'", 
           :order => :screen_name
  has_many :games, foreign_key: "user_id"
  
  def skip_confirmation!
  	self.confirmed_at = Time.now
  end

  def self.find_by_user_id(user_id)
    find(:user_id => id).first
  end
end
