class Team < ActiveRecord::Base

	has_many :players
	has_many :participants, :dependent => :destroy
	has_many :games, :through => :participants
	has_many :tickers
	
	def self.search(search)
		if search
			find(:all, :conditions => ['team_name LIKE ?', "%#{search}%"])
		else
    		find(:all)
  		end
	end
end
