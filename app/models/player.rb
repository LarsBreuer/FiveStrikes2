class Player < ActiveRecord::Base

	belongs_to :team
	has_many :tickers, :dependent => :destroy
	has_many :games, :through => :tickers
	has_many :line_items
	
	def self.search(team_id, player_forename, player_surename)
		if team_id
			if player_forename && player_surename
				find(:all, :conditions => ['team_id = ? AND player_forename LIKE ? AND player_surename LIKE ?', team_id, "%#{player_forename}%", "%#{player_surename}%"])
			else
				find(:all, :conditions => ['team_id = ?', team_id])
			end
		else
    		find(:all)
  		end
	end
	
end
