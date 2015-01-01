class Player < ActiveRecord::Base

	belongs_to :team
	has_many :tickers, :dependent => :destroy
	has_many :games, :through => :tickers
	has_many :line_items
	
	def self.search(team_id, player_name)
		if team_id
			if player_name
				find(:all, :conditions => ['team_id = ? AND player_name LIKE ?', team_id, "%#{player_name}%"])
			else
				find(:all, :conditions => ['team_id = ?', team_id])
			end
		else
    		find(:all)
  		end
	end
end
