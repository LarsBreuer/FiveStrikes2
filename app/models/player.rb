class Player < ActiveRecord::Base
	require 'csv'
  #require 'iconv'

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
	def self.import(file_in, team_id)

    # Datei umwandeln wegen Umlaute (ä,ü,ö)
    #logger.debug "Datei umwandeln"
    #file = Iconv.conv("UTF8", "LATIN3", file_in)

    # Daten aus der CSV herauslesen
    CSV.foreach(file.path, headers: true) do |row|

    	player_hash = row.to_hash 
    	player = Player.where(player_forename: player_hash["player_forename"], player_surename: player_hash["player_surename"], team_id: team_id)
    	if player.count == 0
     		Player.create!(player_hash.merge({ team_id: team_id }))
    	end
    end
  end

  def get_player_position_by_id(position_id)
  	if position_id == '1001'
  		position = I18n.t('basic.goalkeeper')
  	end
  	if position_id == '1002'
  		position = I18n.t('basic.left_wing')
  	end
  	if position_id == '1003'
  		position = I18n.t('basic.left_back')
  	end
  	if position_id == '1004'
  		position = I18n.t('basic.center_back')
  	end
  	if position_id == '1005'
  		position = I18n.t('basic.right_back')
  	end
  	if position_id == '1006'
  		position = I18n.t('basic.right_wing')
  	end
  	if position_id == '1007'
  		position = I18n.t('basic.pivot')
  	end
  	return position
  end

  def get_player_games
    
    game_array = Array.new

    self.games.each do |game|
      unless game_array.include?(game)
        game_array.push(game)
      end
    end

    return game_array

  end
	
end
