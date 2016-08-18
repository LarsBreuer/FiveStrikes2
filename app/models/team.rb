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

		team_type = ""
		gender = ""
		age = ""
		level = ""
# ToDo => Bezeichnung wie "Herren" internationalisieren
		if team_type_id

			gender_id = team_type_id.to_s[2].to_i
			age_id = team_type_id.to_s[3].to_i
			level_id = team_type_id.to_s[4].to_i


			if gender_id == 1 && age_id == 1
				gender = "Herren"
			end
			if gender_id == 2 && age_id == 1
				gender = "Damen"
			end
			if gender_id == 1 && age_id > 1
				gender = "männlich"
			end
			if gender_id == 2 && age_id > 1
				gender = "weiblich"
			end
			if age_id == 2
				age = "A"
			end
			if age_id == 3
				age = "B"
			end
			if age_id == 4
				age = "C"
			end
			if age_id == 5
				age = "D"
			end
			if age_id == 6
				age = "E"
			end
			if level_id
				level = level_id.to_s
			end
			if age_id == 1
				team_type = level + ". " + gender
			end
			if age_id > 1
				team_type = age + level + " " + gender
			end
		end

		return team_type

	end

	def get_team_games
    
    	game_array = Array.new

    	games = Game.find(:all, :conditions => ['team_home_id = ? OR team_away_id = ?', self.id, self.id])

    	games.each do |game|
      		unless game_array.include?(game)
        		game_array.push(game)
      		end
      	end

    	return game_array

  	end

end
