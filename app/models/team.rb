class Team < ActiveRecord::Base
	
	has_many :players
	has_many :ticker_activities
	belongs_to :club
	has_many :line_items

	def self.search(team_name, club_id, team_type)
		if team_name
			find(:all, :conditions => ['team_club_name LIKE ?', "%#{team_name}%"])
		else
			if club_id && team_type
				find(:all, :conditions => ['club_id = ? AND team_type_id = ?', club_id, team_type])
			else
    			find(:all)
    		end
  		end
	end

	def team_type(team_type_id)
		logger.debug "Team: #{team_type_id}"

		case team_type_id
			when 10111 then "1. Herren"
			when 10112 then "2. Herren"
			when 10121 then "A1 männlich"
			when 10211 then "1. Damen"
			when 10222 then "A2 weiblich"
		end

	end

end
