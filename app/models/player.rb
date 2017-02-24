require 'csv'

class Player < ActiveRecord::Base
	belongs_to :team
	has_many :ticker_activities, :dependent => :destroy
	has_many :games, :through => :ticker_activities
	has_many :line_items

	CSV_POSITION_MAPPING = {
		TW: '1001',
		LA: '1002',
		RL: '1003',
		RM: '1004',
		RR: '1005',
		RA: '1006',
		KM: '1007'
	}

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
		if (team = Team.find(team_id))
			if (col_sep = detect_column_separator(file_in.path))
				puts "Column separator detected: #{col_sep}"
				# Daten aus der CSV herauslesen
				CSV.foreach(file_in.path, headers: true, col_sep: col_sep, encoding:'iso-8859-1:utf-8') do |row|
					player_hash = row.to_hash
					player_hash.keys.each do |k|
						nk = k.gsub(/[^0-9A-Za-z_]/, '')
						player_hash[nk] = player_hash[k].encode("iso-8859-1").force_encoding("utf-8") if player_hash[k]
						player_hash.delete(k) if nk != k
					end
					if player_hash['player_position_first'] and not player_hash['player_position_first'].empty?
						player_hash['player_position_first'] = CSV_POSITION_MAPPING[player_hash['player_position_first'].to_sym]
					end
					if player_hash and not player_hash.empty?
						puts "CSV row: #{player_hash.inspect}"
						if player_hash["player_forename"].present? and player_hash["player_surename"].present?
							players = team.players.where(player_forename: player_hash["player_forename"], player_surename: player_hash["player_surename"])
							team.players.create(player_hash) if players.count == 0
						end
					end
				end
				return true
			end
		end
		false
  end

	def self.detect_column_separator(path)
	  first_line = File.open(path).first
	  return nil unless first_line
	  detected = {}
	  [",", ";"].each { |delim| detected[delim] = first_line.count(delim) }
	  detected = detected.sort { |a, b| b[1] <=> a[1] }
	  detected.size > 0 ? detected[0][0] : nil
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
