class Team < ActiveRecord::Base
	
	has_many :players
	has_many :tickers
	belongs_to :club
	has_many :line_items
	
	def self.search(search)
		if search
			find(:all, :conditions => ['team_name LIKE ?', "%#{search}%"])
		else
    		find(:all)
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
