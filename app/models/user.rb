class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :token_authenticatable
  # , :token_authenticatable entfernen? Siehe http://blog.plataformatec.com.br/2013/08/devise-3-1-now-with-more-secure-defaults/

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

  
  # aus: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  # Anfang

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
 
  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  # Ende

end
