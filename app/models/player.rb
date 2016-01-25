class Player < ActiveRecord::Base
	require 'csv'

	belongs_to :team
	has_many :ticker_activities, :dependent => :destroy
	has_many :games, :through => :ticker_activities
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

	# Import CSV-File
	def self.import(file)
    	CSV.foreach(file.path, headers: true) do |row|

      		player_hash = row.to_hash 
# ToDo => Doppelte Spieler nur in der gleichen Mannschaft abfragen
      		player = Player.where(player_forename: player_hash["player_forename"], player_surename: player_hash["player_surename"])
      		if player.count == 0
# ToDo => Team ID der Spieler automatisch einfügen => siehe http://stackoverflow.com/questions/34871896/importing-csv-files-in-rails-add-certain-fields
# Player.create!(player_hash.merge({ team_id: team_id }))
# ToDo => Umlaute ä,ö,ü beachten
        		Player.create!(player_hash)
      		end
    	end
  	end
	
end
