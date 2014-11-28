class Team < ActiveRecord::Base
	
	has_many :players
	has_many :tickers
	belongs_to :club
	
	def self.search(search)
		if search
			find(:all, :conditions => ['team_name LIKE ?', "%#{search}%"])
		else
    		find(:all)
  		end
	end

	def team_club_name(club_id)
		logger.debug "Club ID: #{club_id}"
		Club.find(:first, :conditions => [ "id = ?", club_id ])
	end

	def team_type(team_type_id)
		logger.debug "Team: #{team_type_id}"

		case team_type_id
			when 111 then "1. Herren"
			when 112 then "2. Herren"
			when 121 then "A1 männlich"
			when 211 then "1. Damen"
			when 222 then "A2 weiblich"
		end

	end

end
