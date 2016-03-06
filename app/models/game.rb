class Game < ActiveRecord::Base

  searchkick
  # ToDo => Eventuell doch Verweis auf Team Home und Team Away einrichten, statt nur auf die ID zu verweisen
  has_many :ticker_activities, :dependent => :destroy, :order => 'time ASC'
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  # ToDo => Überprüfung, ob Spiel tatsächlich zerstört werden darf, einrichten
  # before_destroy :ensure_not_referenced_by_any_line_item

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

  def get_player_home(gameID)
    
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


