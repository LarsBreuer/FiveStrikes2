class Game < ActiveRecord::Base

  # ToDo => Eventuell doch Verweis auf Team Home und Team Away einrichten, statt nur auf die ID zu verweisen
  has_many :ticker_activities, :dependent => :destroy, :order => 'time ASC'
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  # ToDo => Überprüfung, ob Spiel tatsächlich zerstört werden darf, einrichten
  # before_destroy :ensure_not_referenced_by_any_line_item

  #
  #
  # Suchfunktion
  #
  #

  def self.search_items(search)
    if search
      find(:all, :conditions => ['club_home_name LIKE ? OR club_away_name LIKE ?', "%#{search}%", "%#{search}%"])
    else
      find(:all)
    end
  end

  #
  #
  # Informationen zur Mannschaft und Spieler
  #
  #

  def get_club_name_by_team_id(team_id)
	 Team.find(:first, :conditions => [ "id = ?", team_id ]).club.club_name
  end 

  def get_club_name_short_by_team_id(team_id)
   Team.find(:first, :conditions => [ "id = ?", team_id ]).club.club_name_short
  end

  def get_player_name_by_id(playerID)
   player_forename = Player.find(:first, :conditions => [ "id = ?", playerID ]).player_forename
   player_surename = Player.find(:first, :conditions => [ "id = ?", playerID ]).player_surename
   return player_forename + " " + player_surename
  end

  def get_player_home()
    
    player_array = Array.new
    
    self.players.each do |player|
      if player.team_id == self.team_home_id
        unless player_array.include?(player.id)
          player_array.push(player.id)
        end
      end
    end

    return player_array

  end

  #
  #
  # Spielstatistiken
  #
  #

  def get_game_stat()

    game_stat_array = Array.new
    row_width = 300

  # 0 => Titel Tore gesamt
    game_stat_array.push(I18n.t('basic.goals_overall'))
    # 1 => Tore gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id, self.id))
    # 2 => Tore gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id, self.id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Tore geworfen hat
    max_width = game_stat_array[1]
    if game_stat_array[2] > game_stat_array[1]
      max_width = game_stat_array[2]
    end
    if game_stat_array[1] > game_stat_array[2]
      max_width = game_stat_array[1]
    end
    array_length = game_stat_array.count
    # 3 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 4 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 5 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 6 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 7 => Titel Versuche gesamt
    game_stat_array.push(I18n.t('basic.attempts'))
    # 8 => Versuche gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id, self.id) + count_team_miss(self.team_home_id, self.id))
    # 9 => Versuche gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id, self.id) + count_team_miss(self.team_away_id, self.id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Versuche hatte
    max_width = game_stat_array[8]
    if game_stat_array[9] > game_stat_array[8]
      max_width = game_stat_array[9]
    end
    if game_stat_array[8] > game_stat_array[9]
      max_width = game_stat_array[8]
    end
    array_length = game_stat_array.count
    # 10 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 11 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 12 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 13 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 14 => Titel Effektivität gesamt
    game_stat_array.push(I18n.t('basic.efficiency'))
    # 15 => Effektivität gesamt Heim
    percent_home = team_effective(self.team_home_id, self.id)
    percentstring = percent_home.to_s
    string = percentstring + "%"
    game_stat_array.push(string)
    # 16 => Effektivität gesamt Auswärts
    percent_away = team_effective(self.team_away_id, self.id)
    string = "#{percent_away}%"
    game_stat_array.push(string)
    array_length = game_stat_array.count
    # 17 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * percent_home / 100))
    # 18 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * percent_home / 100)
    # 19 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * percent_away / 100)
    # 20 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * percent_away / 100))
  # 21 => Titel 7m-Tore gesamt
    game_stat_array.push(I18n.t('basic.7m_goals_overall'))
    # 22 => 7m-Tore gesamt Heim
    game_stat_array.push(count_team_activity(10101, self.team_home_id))
    # 23 => 7m-Tore gesamt Auswärts
    game_stat_array.push(count_team_activity(10101, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr 7m-Tore geworfen hat
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 1]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    if game_stat_array[array_length - 2] > game_stat_array[array_length - 1]
      max_width = game_stat_array[array_length - 2]
    end
    # 24 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 25 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 26 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 27 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 28 => Titel Versuche gesamt
    game_stat_array.push(I18n.t('basic.attempts'))
    # 29 => Versuche gesamt Heim
    game_stat_array.push(count_team_activity(10101, self.team_home_id) + count_team_activity(10151, self.team_home_id))
    # 30 => Versuche gesamt Auswärts
    game_stat_array.push(count_team_activity(10101, self.team_away_id) + count_team_activity(10151, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Versuche hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 1]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    if game_stat_array[array_length - 2] > game_stat_array[array_length - 1]
      max_width = game_stat_array[array_length - 2]
    end
    array_length = game_stat_array.count
    # 31 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 32 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 33 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 34 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 35 => Titel Effektivität gesamt
    game_stat_array.push(I18n.t('basic.efficiency'))
    # 36 => Effektivität gesamt Heim
    percent_home = team_effective_7m(self.team_home_id)
    string = "#{percent_home}%"
    game_stat_array.push(string)
    # 37 => Effektivität gesamt Auswärts
    percent_away = team_effective_7m(self.team_away_id)
    string = "#{percent_away}%"
    game_stat_array.push(string)
    array_length = game_stat_array.count
    # 38 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * percent_home / 100))
    # 39 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * percent_home / 100)
    # 40 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * percent_away / 100)
    # 41 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * percent_away / 100))
  # 42 => Titel Tempogegenstoss-Tore gesamt
    game_stat_array.push(I18n.t('basic.fb_goals_overall'))
    # 43 => Tempogegenstoss-Tore gesamt Heim
    game_stat_array.push(count_team_activity(10102, self.team_home_id))
    # 44 => Tempogegenstoss-Tore gesamt Auswärts
    game_stat_array.push(count_team_activity(10102, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Tempogegenstoss-Tore geworfen hat
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 1]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    if game_stat_array[array_length - 2] > game_stat_array[array_length - 1]
      max_width = game_stat_array[array_length - 2]
    end
    # 45 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 46 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 47 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 48 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 49 => Titel Versuche gesamt
    game_stat_array.push(I18n.t('basic.attempts'))
    # 50 => Versuche gesamt Heim
    game_stat_array.push(count_team_activity(10102, self.team_home_id) + count_team_activity(10152, self.team_home_id))
    # 51 => Versuche gesamt Auswärts
    game_stat_array.push(count_team_activity(10102, self.team_away_id) + count_team_activity(10152, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Versuche hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 1]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    if game_stat_array[array_length - 2] > game_stat_array[array_length - 1]
      max_width = game_stat_array[array_length - 2]
    end
    array_length = game_stat_array.count
    # 52 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 53 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 54 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 55 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 56 => Titel Effektivität gesamt
    game_stat_array.push(I18n.t('basic.efficiency'))
    # 57 => Effektivität gesamt Heim
    percent_home = team_effective_fb(self.team_home_id)
    string = "#{percent_home}%"
    game_stat_array.push(string)
    # 58 => Effektivität gesamt Auswärts
    percent_away = team_effective_fb(self.team_away_id)
    string = "#{percent_away}%"
    game_stat_array.push(string)
    array_length = game_stat_array.count
    # 59 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * percent_home / 100))
    # 60 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * percent_home / 100)
    # 61 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * percent_away / 100)
    # 62 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * percent_away / 100))
  # 63 => Titel Technische Fehler gesamt
    game_stat_array.push(I18n.t('basic.tech_faults'))
    # 64 => Technische Fehler Heim
    game_stat_array.push(count_team_activity(10300, self.team_home_id) + count_team_activity(10301, self.team_home_id) + count_team_activity(10302, self.team_home_id) + count_team_activity(10303, self.team_home_id) + count_team_activity(10304, self.team_home_id) + count_team_activity(10305, self.team_home_id) + count_team_activity(10306, self.team_home_id) + count_team_activity(10307, self.team_home_id) + count_team_activity(10308, self.team_home_id))
    # 65 => Technische Fehler Auswärts
    game_stat_array.push(count_team_activity(10300, self.team_away_id) + count_team_activity(10301, self.team_away_id) + count_team_activity(10302, self.team_away_id) + count_team_activity(10303, self.team_away_id) + count_team_activity(10304, self.team_away_id) + count_team_activity(10305, self.team_away_id) + count_team_activity(10306, self.team_away_id) + count_team_activity(10307, self.team_away_id) + count_team_activity(10308, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Fehler hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 1]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    if game_stat_array[array_length - 2] > game_stat_array[array_length - 1]
      max_width = game_stat_array[array_length - 2]
    end
    array_length = game_stat_array.count
    # 66 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 67 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 68 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 69 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    

    return game_stat_array

  end

  def get_game_possession()

    game_stat_array = Array.new
    row_width = 300

  # 0 => Titel Tore gesamt
    game_stat_array.push(I18n.t('basic.goals_overall'))
    # 1 => Tore gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id, self.id))
    # 2 => Tore gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id, self.id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Tore geworfen hat
    max_width = game_stat_array[1]
    if game_stat_array[2] > game_stat_array[1]
      max_width = game_stat_array[2]
    end
    if game_stat_array[1] > game_stat_array[2]
      max_width = game_stat_array[1]
    end
    array_length = game_stat_array.count
    # 3 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 4 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 5 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 6 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 7 => Titel Versuche gesamt
    game_stat_array.push(I18n.t('basic.attempts'))
    # 8 => Versuche gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id, self.id) + count_team_miss(self.team_home_id, self.id))
    # 9 => Versuche gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id, self.id) + count_team_miss(self.team_away_id, self.id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Versuche hatte
    max_width = game_stat_array[8]
    if game_stat_array[9] > game_stat_array[8]
      max_width = game_stat_array[9]
    end
    if game_stat_array[8] > game_stat_array[9]
      max_width = game_stat_array[8]
    end
    array_length = game_stat_array.count
    # 10 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
    # 11 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
    # 12 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
    # 13 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
  # 14 => Titel Effektivität gesamt
    game_stat_array.push(I18n.t('basic.efficiency'))
    # 15 => Effektivität gesamt Heim
    percent_home = team_effective(self.team_home_id, self.id)
    percentstring = percent_home.to_s
    string = percentstring + "%"
    game_stat_array.push(string)
    # 16 => Effektivität gesamt Auswärts
    percent_away = team_effective(self.team_away_id, self.id)
    string = "#{percent_away}%"
    game_stat_array.push(string)
    array_length = game_stat_array.count
    # 17 => Breite des grauen Balkens der Heimmannschaft berechnen
    game_stat_array.push(row_width - (row_width * percent_home / 100))
    # 18 => Breite des blauen Balkens der Heimmannschaft
    game_stat_array.push(row_width * percent_home / 100)
    # 19 => Breite des roten Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width * percent_away / 100)
    # 20 => Breite des grauen Balkens der Auswärtsmannschaft
    game_stat_array.push(row_width - (row_width * percent_away / 100))


    return game_stat_array

  end
  #
  #
  # Tore / Aktionen zählen
  #
  #

  # Aktivitäten
  def count_team_activity(activityID, teamID)
    self.ticker_activities.where(:activity_id => activityID, :team_id => teamID).count
  end

  # Tore zu einer Spielzeit
  def count_team_goals_time(teamID, time)
    self.ticker_activities.where("activity_id = ? AND team_id = ? AND time <= ?", 10100, teamID, time).count
  end

  # Tore eines Teams
  def count_team_goals(teamID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ? AND game_id <= ?", 10100, 10101, 10102, teamID, gameID).count
  end

  # Fehlwürfe eines Teams
  def count_team_miss(teamID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ? AND game_id <= ?", 10150, 10151, 10152, teamID, gameID).count
  end

  # Quote eines Teams
  def team_effective(teamID, gameID)
    attempts = self.count_team_goals(teamID, gameID) + self.count_team_miss(teamID, gameID)
    if attempts > 0
      effective = self.count_team_goals(teamID, gameID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  def team_effective_7m(teamID)
    attempts = self.count_team_activity(10101, teamID) + self.count_team_activity(10151, teamID)
    if attempts > 0
      effective = self.count_team_activity(10101, teamID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  def team_effective_fb(teamID)
    attempts = self.count_team_activity(10102, teamID) + self.count_team_activity(10152, teamID)
    if attempts > 0
      effective = self.count_team_activity(10102, teamID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  # Tore eines Spielers
  def count_player_goals(playerID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ? AND game_id <= ?", 10100, 10101, 10102, playerID, gameID).count
  end

  # Fehlwürfe eines Spielers
  def count_player_miss(playerID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ? AND game_id <= ?", 10150, 10151, 10152, playerID, gameID).count
  end

  #
  #
  # Betsen Torschützen ermitteln
  #
  #

  def get_top_scorer_hash(gameID)
    player_hash = Hash.new

    self.players.each do |player|

      player_hash[player.id] = self.count_player_goals(player.id, gameID)

    end

    return player_hash

  end

  def get_top_scorer_goals(gameID)

    return self.get_top_scorer_hash(gameID).max_by{|k,v| v}[1]

  end

  def get_top_scorer_name(gameID)

    playerID = self.get_top_scorer_hash(gameID).max_by{|k,v| v}[0]
    player = self.players.where("player_id = ?", playerID).first

    return player.player_forename + " " + player.player_surename

  end

  #
  #
  # Beste Effektivität ermitteln
  #
  #

  def get_top_effective_hash(gameID)
    player_hash = Hash.new

    self.players.each do |player|

      player_goal = self.count_player_goals(player.id, gameID)
      player_miss = self.count_player_miss(player.id, gameID)
      if (player_goal + player_miss) > 0
        player_hash[player.id] = player_goal / (player_goal + player_miss) * 100
      else
        player_hash[player.id] = 0
      end
    end

    return player_hash

  end

  def get_top_effective_percent(gameID)

    return self.get_top_effective_hash(gameID).max_by{|k,v| v}[1]

  end

  def get_top_effective_name(gameID)

    playerID = self.get_top_effective_hash(gameID).max_by{|k,v| v}[0]
    player = self.players.where("player_id = ?", playerID).first

    return player.player_forename + " " + player.player_surename

  end

  #
  #
  # Relative Statistiken
  #
  #

  # Ergebnis Mannschaft in Führung
  def get_team_lead(gameID, home_or_away, modus)

    goals_home = 0
    goals_away = 0
    time_lead_change = 0
    time_lead_home = 0
    time_lead_away = 0
    time_draw = 0

    if self.duration_halftime
      duration_halftime = self.duration_halftime
    else
      duration_halftime = 1800
    end

    self.ticker_activities.each do |ticker_activity|
      
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102

        if ticker_activity.home_or_away == 1
          goals_home = goals_home + 1
        end
        if ticker_activity.home_or_away == 0
          goals_away = goals_away + 1
        end

        # Heimmannschaft ist in Führung gegangen
        if goals_home - goals_away == 1 && ticker_activity.home_or_away == 1
          time_draw = time_draw + ticker_activity.time - time_lead_change
          time_lead_change = ticker_activity.time
        end

        # Auswärtsmannschaft ist in Führung gegangen
        if goals_home - goals_away == -1 && ticker_activity.home_or_away == 0
          time_draw = time_draw + ticker_activity.time - time_lead_change
          time_lead_change = ticker_activity.time
        end

        # Unentschieden
        if goals_home - goals_away == 0
          # Heimmannschaft hat Rückstand egalisiert
          if ticker_activity.home_or_away == 1
            time_lead_away = time_lead_away + ticker_activity.time - time_lead_change
            time_lead_change = ticker_activity.time
          end
          # Auswärtsmannschaft hat Rückstand egalisiert
          if ticker_activity.home_or_away == 0
            time_lead_home = time_lead_home + ticker_activity.time - time_lead_change
            time_lead_change = ticker_activity.time
          end
        end
      end
    end

    # Restzeit bis zum Ende des Spiels ermitteln
    # Die Heimmannschaft lag bis zum Ende des Spiels in Führung
    if goals_home - goals_away > 0
      time_lead_home = time_lead_home + (duration_halftime * 2) - time_lead_change
    end
    # Die Auswärtsmannschaft lag bis zum Ende des Spiels in Führung
    if goals_home - goals_away < 0
      time_lead_away = time_lead_away + (duration_halftime * 2) - time_lead_change
    end
    # Zum Ende des Spiels Stand es Unentschieden
    if goals_home == goals_away
      time_draw = time_draw + (duration_halftime * 2) - time_lead_change
    end

# ToDo => Diese Funktion wird mehrmals aufgerufen. Kann man diese auch nur einmal aufrufen und das Ergebnis mehrmals verwenden?

    # Falls nach der längsten Führung gefragt wird
    if home_or_away
      if home_or_away == 1
        result = TickerActivity.convert_seconds_to_time(time_lead_home)
      end
      if home_or_away == 0
        result = TickerActivity.convert_seconds_to_time(time_lead_away)
      end
    else
      if time_lead_home > time_lead_away
        if modus == "name"
          result = self.club_home_name
        end
        if modus == "time"
          result = TickerActivity.convert_seconds_to_time(time_lead_home)
        end
      else
        if modus == "name"
          result = self.club_away_name
        end
        if modus == "time"
          result = TickerActivity.convert_seconds_to_time(time_lead_away)
        end
      end
    end

    return result

  end

end


