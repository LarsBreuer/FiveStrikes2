class Team < ActiveRecord::Base

	has_many :players
	has_many :participants, :dependent => :destroy
	has_many :games, :through => :participants
	
end
