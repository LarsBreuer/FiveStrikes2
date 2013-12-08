class Player < ActiveRecord::Base

	belongs_to :team
	has_many :tickers, :dependent => :destroy
	has_many :games, :through => :tickers
	
	def self.search(team_id, player_name)
		if team_id
			if player_name
				find(:all, :conditions => ['team_id LIKE ? AND player_name LIKE ?', "%#{team_id}%", "%#{player_name}%"])
			else
				find(:all, :conditions => ['team_id = ?', team_id])
			end
		else
    		find(:all)
  		end
	end
end
