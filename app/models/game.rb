class Game < ActiveRecord::Base
  
  # ToDo => Eventuell doch Verweis auf Team Home und Team Away einrichten, statt nur auf die ID zu verweisen
  has_many :ticker_activities, :dependent => :destroy, :order => 'time ASC'
  has_many :ticker_events, :dependent => :delete_all, :order => 'time ASC'
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  require 'date'

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

  def get_player_away()
    
    player_array = Array.new
    
    self.players.each do |player|
      if player.team_id == self.team_away_id
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

  def get_game_ticker()

    game_ticker_array = Array.new

    

    return game_ticker_array

  end

  def get_game_stat()

    game_stat_array = Array.new
    row_width = 300

  # 0 => Titel Tore gesamt
    game_stat_array.push(I18n.t('basic.goals_overall'))
    # 1 => Tore gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id))
    # 2 => Tore gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Tore geworfen hat
    max_width = game_stat_array[1]
    if game_stat_array[2] > game_stat_array[1]
      max_width = game_stat_array[2]
    end
    if game_stat_array[1] > game_stat_array[2]
      max_width = game_stat_array[1]
    end
    array_length = game_stat_array.count
    # 3 - 6 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 7 => Titel Versuche gesamt
    game_stat_array.push(I18n.t('basic.attempts'))
    # 8 => Versuche gesamt Heim
    game_stat_array.push(count_team_goals(self.team_home_id) + count_team_miss(self.team_home_id))
    # 9 => Versuche gesamt Auswärts
    game_stat_array.push(count_team_goals(self.team_away_id) + count_team_miss(self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Versuche hatte
    max_width = game_stat_array[8]
    if game_stat_array[9] > game_stat_array[8]
      max_width = game_stat_array[9]
    end
    if game_stat_array[8] > game_stat_array[9]
      max_width = game_stat_array[8]
    end
    array_length = game_stat_array.count
    # 10 - 13 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
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
    # 24 - 27 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
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
    # 31 - 34 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
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
    # 45 - 48 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
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
    # 52 - 55 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
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
    # 66 - 69 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
    

    return game_stat_array

  end

  def get_game_possession()

    game_stat_array = Array.new
    row_width = 300
    intCurrentPossession = 2
    intPossessionHome = 0
    intPossessionAway = 0
    intChangePossessionTime = 0
    intPossessionTimeHome = 0
    intPossessionTimeAway = 0
    intGoalDifference = 0
    duration = 1800
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end
    intTimePossessionAttemptHome = 0
    intTimePossessionAttemptAway = 0

  # Ballbesitz-Statistik vorbereiten
    # Alle Ticker eines Spiels aufrufen
    self.ticker_activities.each do |ticker_activity|

      intTickerTime = ticker_activity.time

      # Angriffe zählen
      if ticker_activity.activity_id == 10099 && ticker_activity.home_or_away == 1
        unless intCurrentPossession == 1

          intPossessionHome = intPossessionHome + 1        # Zähle Angriff hinzu
          intPossessionTimeAway = intPossessionTimeAway + intTickerTime - intChangePossessionTime  # Trage Zeit ein, die die Auswärtsmannschaft in Ballbesitz war
          intChangePossessionTime = intTickerTime
          intCurrentPossession = 1

        end
      end

      if ticker_activity.activity_id == 10099 && ticker_activity.home_or_away == 0
        unless intCurrentPossession == 0

          intPossessionAway = intPossessionAway + 1        # Zähle Angriff hinzu
          intPossessionTimeHome = intPossessionTimeHome + intTickerTime - intChangePossessionTime  # Trage Zeit ein, die die Auswärtsmannschaft in Ballbesitz war
          intChangePossessionTime = intTickerTime
          intCurrentPossession = 0

        end
      end

    end

    intPossessionTimeHome = intPossessionTimeHome / 1000
    intPossessionTimeAway = intPossessionTimeAway / 1000

    # Wenn zum Spielende eine Mannschaft in Ballbesitz, dann Restzeit eintragen
    if intCurrentPossession == 1
      intPossessionTimeHome = intPossessionTimeHome + duration * 2 * 60 - intChangePossessionTime
    end
    if intCurrentPossession == 0
      intPossessionTimeAway = intPossessionTimeAway + duration * 2 * 60 - intChangePossessionTime
    end

    # Durchschnittliche Zeit pro Angriff errechnen
    if intPossessionHome != 0
      intTimePossessionAttemptHome = intPossessionTimeHome / intPossessionHome
    end
    if intPossessionAway != 0
      intTimePossessionAttemptAway = intPossessionTimeAway / intPossessionAway
    end

  # 0 => Titel Angriffe
    game_stat_array.push(I18n.t('basic.attacks'))
    # 1 => Angriffe Heim
    game_stat_array.push(intPossessionHome)
    # 2 => Angriffe Auswärts
    game_stat_array.push(intPossessionAway)
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    max_width = game_stat_array[1]
    if game_stat_array[2] > game_stat_array[1]
      max_width = game_stat_array[2]
    end
    if game_stat_array[1] > game_stat_array[2]
      max_width = game_stat_array[1]
    end
    array_length = game_stat_array.count
    # 3 - 6 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 7 => Titel Zeit im Ballbesitz
    game_stat_array.push(I18n.t('basic.time'))
    # 8 => Zeit Heim
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intPossessionTimeHome))
    # 9 => Zeit Auswärts
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intPossessionTimeAway))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Zeit hatte
    max_width = intPossessionTimeHome
    if intPossessionTimeAway > intPossessionTimeHome
      max_width = intPossessionTimeAway
    end
    if intPossessionTimeHome > intPossessionTimeAway
      max_width = intPossessionTimeHome
    end
    array_length = game_stat_array.count
    # 10 - 13 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * intPossessionTimeHome / max_width))
      game_stat_array.push(row_width * intPossessionTimeHome / max_width)
      game_stat_array.push(row_width * intPossessionTimeAway / max_width)
      game_stat_array.push(row_width - (row_width * intPossessionTimeAway / max_width))
    end
  # 14 => Durchschnittliche Zeit im Ballbesitz
    game_stat_array.push(I18n.t('basic.time_attack'))
    # 15 => Zeit Heim
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimePossessionAttemptHome))
    # 16 => Zeit Auswärts
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimePossessionAttemptAway))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Zeit hatte
    max_width = intTimePossessionAttemptHome
    if intTimePossessionAttemptAway > intTimePossessionAttemptHome
      max_width = intTimePossessionAttemptAway
    end
    if intTimePossessionAttemptHome > intTimePossessionAttemptAway
      max_width = intTimePossessionAttemptHome
    end
    array_length = game_stat_array.count
    # 17 - 20 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * intTimePossessionAttemptHome / max_width))
      game_stat_array.push(row_width * intTimePossessionAttemptHome / max_width)
      game_stat_array.push(row_width * intTimePossessionAttemptAway / max_width)
      game_stat_array.push(row_width - (row_width * intTimePossessionAttemptAway / max_width))
    end


    return game_stat_array

  end

  def get_game_lead()

    game_stat_array = Array.new
    row_width = 300
    intGoalDifference = 0
    intMaxLeadHome = 0
    intMaxLeadAway = 0
    intTimeLeadHome = 0
    intTimeLeadAway = 0
    intTimeDraw = 0
    intTimeLeadChange = 0
    duration = 1800
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end

  # Zeit Führung und Unentschieden ermitteln
    # Alle Ticker eines Spiels aufrufen
    self.ticker_activities.each do |ticker_activity|

      intTickerTime = ticker_activity.time

      # Wurde ein Tor geschossen?
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102
              
        # Hat das Heimteam das Tor geschossen?
        if ticker_activity.home_or_away == 1
            
          intGoalDifference = intGoalDifference + 1
            
          # Maximale Führung überprüfen
          if intGoalDifference > intMaxLeadHome
            intMaxLeadHome = intGoalDifference
          end
            
          # Kommt es durch das Tor zum Unentschieden?
          if intGoalDifference == 0
            intTimeLeadAway = intTimeLeadAway + intTickerTime - intTimeLeadChange
            intTimeLeadChange = intTickerTime
          end
            
          # Geht die Heimmannschaft durch das Tor in Führung?
          if intGoalDifference == 1
            intTimeDraw = intTimeDraw + intTickerTime - intTimeLeadChange
            intTimeLeadChange = intTickerTime
          end
        
        end
            
        # Hat das Auswärtsteam das Tor geschossen?
        if ticker_activity.home_or_away == 0
            
          intGoalDifference = intGoalDifference - 1
            
          # Maximale Führung überprüfen
          if intGoalDifference < intMaxLeadAway
            intMaxLeadAway = intGoalDifference
          end
            
          # Kommt es durch das Tor zum Unentschieden?
          if intGoalDifference == 0
            intTimeLeadHome = intTimeLeadHome + intTickerTime - intTimeLeadChange
            intTimeLeadChange = intTickerTime
          end
            
          # Geht die Auswärtsmannschaft durch das Tor in Führung?
          if intGoalDifference == -1              
            intTimeDraw = intTimeDraw + intTickerTime - intTimeLeadChange
            intTimeLeadChange = intTickerTime
          end

        end
      end
    end

    intTimeLeadHome = intTimeLeadHome / 1000
    intTimeLeadAway = intTimeLeadAway / 1000
    intTimeDraw = intTimeDraw / 1000

    # Führung oder Unentschieden zum Spielende eintragen
    if intGoalDifference > 0
      intTimeLeadHome = intTimeLeadHome + (duration * 2 * 60) - intTimeLeadChange
    end
    if intGoalDifference < 0
      intTimeLeadAway = intTimeLeadAway + (duration * 2 * 60) - intTimeLeadChange
    end
    if intGoalDifference == 0
      intTimeDraw = intTimeDraw + (duration * 2 * 60) - intTimeLeadChange
    end

    # Betrag der maximalen Führung der Auswärtsmannschaft, da sonst negativ 
    intMaxLeadAway= intMaxLeadAway.abs

  # 0 => Titel Führung
    game_stat_array.push(I18n.t('basic.lead'))
    # 1 => Führung Heim
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimeLeadHome))
    # 2 => Führung Auswärts
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimeLeadAway))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft länger in Führung war
    array_length = game_stat_array.count
    max_width = intTimeLeadHome
    if intTimeLeadAway > intTimeLeadHome
      max_width = intTimeLeadAway
    end
    array_length = game_stat_array.count
    # 3 - 6 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * intTimeLeadHome / max_width))
      game_stat_array.push(row_width * intTimeLeadHome / max_width)
      game_stat_array.push(row_width * intTimeLeadAway / max_width)
      game_stat_array.push(row_width - (row_width * intTimeLeadAway / max_width))
    end
  # 7 => Titel Unentschieden
    game_stat_array.push(I18n.t('basic.draw'))
    # 8 => Unentschieden Heim
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimeDraw))
    # 9 => Unentschieden Auswärts
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimeDraw))
    # Zeit Unentschieden ermitteln
    max_width = intTimeDraw
    array_length = game_stat_array.count
    # 10 - 13 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * intTimeDraw / max_width))
      game_stat_array.push(row_width * intTimeDraw / max_width)
      game_stat_array.push(row_width * intTimeDraw / max_width)
      game_stat_array.push(row_width - (row_width * intTimeDraw / max_width))
    end
  # 14 => Titel Maximale Führung
    game_stat_array.push(I18n.t('basic.max_lead'))
    # 15 => Angriffe Heim
    game_stat_array.push(intMaxLeadHome)
    # 16 => Angriffe Auswärts
    game_stat_array.push(intMaxLeadAway)
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 17 - 20 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end

    return game_stat_array

  end

  def get_game_history()

    game_stat_array = Array.new
    row_width = 300
    duration = 1800
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end
    time_step = duration / 6
    intGoalDifference = 0
    intMaxLeadHome = 0
    intMaxLeadAway = 0

  # Maximale Führung ermitteln
    # Alle Ticker eines Spiels aufrufen
    self.ticker_activities.each do |ticker_activity|

      intTickerTime = ticker_activity.time

      # Wurde ein Tor geschossen?
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102
              
        # Hat das Heimteam das Tor geschossen?
        if ticker_activity.home_or_away == 1
            
          intGoalDifference = intGoalDifference + 1
            
          # Maximale Führung überprüfen
          if intGoalDifference > intMaxLeadHome
            intMaxLeadHome = intGoalDifference
          end
        
        end
            
        # Hat das Auswärtsteam das Tor geschossen?
        if ticker_activity.home_or_away == 0
            
          intGoalDifference = intGoalDifference - 1
            
          # Maximale Führung überprüfen
          if intGoalDifference < intMaxLeadAway
            intMaxLeadAway = intGoalDifference
          end

        end
      end
    end

    # Betrag der maximalen Führung der Auswärtsmannschaft, da sonst negativ 
    intMaxLeadAway= intMaxLeadAway.abs
    intMaxLeadHome = intMaxLeadHome / 1000
    intMaxLeadAway = intMaxLeadAway / 1000

    max_width = intMaxLeadHome
    if intMaxLeadAway > max_width
      max_width = intMaxLeadAway
    end

    i = 1

  # 0 => Titel Spielstand zur x. Minute
    while i < 13 do
      game_stat_array.push(TickerActivity.convert_seconds_to_time(time_step * i))
      # 1 => Tore Heim
      goals_home = count_team_goals_time(self.team_home_id, time_step * i)
      game_stat_array.push(goals_home)
      # 2 => Tore Auswärts
      goals_away = count_team_goals_time(self.team_away_id, time_step * i)
      game_stat_array.push(goals_away)
      diff_home = 0
      diff_away = 0
      if goals_home > goals_away
        diff_home = goals_home - goals_away
      end
      if goals_away > goals_home
        diff_away = goals_away - goals_home
      end
      # 3 - 6 => Breite der Balken berechnen
      if max_width == 0
        game_stat_array.push(row_width)
        game_stat_array.push(0)
        game_stat_array.push(0)
        game_stat_array.push(row_width)
      else
        game_stat_array.push(row_width - (row_width * diff_home / max_width))
        game_stat_array.push(row_width * diff_home / max_width)
        game_stat_array.push(row_width * diff_away / max_width)
        game_stat_array.push(row_width - (row_width * diff_away / max_width))
      end
      i += 1
    end

    return game_stat_array

  end

  def get_game_penalty()

    game_stat_array = Array.new
    row_width = 300
    duration = 1800
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end
    intPowerplay = 0 
    intGoalsPowerplayHome = 0
    intGoalsPowerplayAway = 0
    intGoalsShorthandedHome = 0
    intGoalsShorthandedAway = 0
    intTimePowerplayChange = 0
    intTimePowerplayHome = 0
    intTimePowerplayAway = 0


  # 0 => Titel Gelbe Karte
    game_stat_array.push(I18n.t('basic.yellow_cards'))
    # 1 => Gelbe Karte Heim
    game_stat_array.push(count_team_activity(10400, self.team_home_id))
    # 2 => Gelbe Karte Auswärts
    game_stat_array.push(count_team_activity(10400, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 3 - 6 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 7 => Titel Rote Karte
    game_stat_array.push(I18n.t('basic.red_cards'))
    # 8 => Rote Karte Heim
    game_stat_array.push(count_team_activity(10403, self.team_home_id))
    # 9 => Rote Karte Auswärts
    game_stat_array.push(count_team_activity(10403, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 10 - 13 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 14 => Titel Zwei Minuten
    game_stat_array.push(I18n.t('basic.two_minutes'))
    # 15 => Rote Karte Heim
    game_stat_array.push(count_team_activity(10401, self.team_home_id))
    # 16 => Rote Karte Auswärts
    game_stat_array.push(count_team_activity(10401, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 17 - 20 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 21 => Titel Zwei plus Zwei
    game_stat_array.push(I18n.t('basic.two_plus_two'))
    # 22 => Rote Karte Heim
    game_stat_array.push(count_team_activity(10402, self.team_home_id))
    # 23 => Rote Karte Auswärts
    game_stat_array.push(count_team_activity(10402, self.team_away_id))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Angriffe hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 24 - 27 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end

  # Zeit in Überzahl + Tore in Überzahl und Unterzahl ermitteln
    # Alle Ticker eines Spiels aufrufen
    self.ticker_activities.each do |ticker_activity|

      intTickerTime = ticker_activity.time

      # Wurde ein Tor geschossen?
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102
              
        # Hat das Heimteam das Tor geworfen?
        if ticker_activity.home_or_away == 1
            
          #Überzahl- und Unterzahltore ermitteln
          if intPowerplay > 0 
            intGoalsPowerplayHome = intGoalsPowerplayHome + 1
          end
          if intPowerplay < 0
            intGoalsShorthandedHome = intGoalsShorthandedHome + 1
          end
        
        end
            
        # Hat das Auswärtsteam das Tor geworfen?
        if ticker_activity.home_or_away == 0
            
          # Überzahl- und Unterzahltore ermitteln
          if intPowerplay < 0
            intGoalsPowerplayAway = intGoalsPowerplayAway + 1
          end
          if intPowerplay > 0
            intGoalsShorthandedAway = intGoalsShorthandedAway + 1
          end

        end
      end

      # Überzahl / Unterzahl eintragen
        
      # Falls eine Zeitstrafe gegeben wurde
      if ticker_activity.activity_id == 10401 || ticker_activity.activity_id == 10402 || ticker_activity.activity_id == 10403
              
        if ticker_activity.home_or_away == 1    # Zeitstrafe für die Heimmannschaft
          intPowerplay = intPowerplay - 1
          if intPowerplay == -1                 # Ist Auswärtsmannschaft in Überzahl gekommen?
            intTimePowerplayChange = intTickerTime
            if intPowerplay == 0                # Wurde Überzahl der Heimmannschaft durch Zeitstrafe beendet
              intTimePowerplayHome = intTimePowerplayHome + intTickerTime - intTimePowerplayChange
            end
          end
        end
        
        if ticker_activity.home_or_away == 0    # Zeitstrafe für die Auswärtsmannschaft
          intPowerplay = intPowerplay + 1
          if intPowerplay == 1                  # Ist Auswärtsmannschaft in Überzahl gekommen?
            intTimePowerplayChange = intTickerTime
          end
          if intPowerplay == 0                  # Wurde Überzahl der Heimmannschaft durch Zeitstrafe beendet
            intTimePowerplayAway = intTimePowerplayAway + intTickerTime - intTimePowerplayChange
          end
        end
      end
        
      # Falls Spieler von Zeitstrafe zurück kommt
      if ticker_activity.activity_id == 10503
        if ticker_activity.home_or_away == 1 
          intPowerplay = intPowerplay + 1
          if intPowerplay == 1                 # Ist Heimmannschaft durch Rückkehr in Überzahl gekommen?
            intTimePowerplayChange = intTickerTime
          end
          if intPowerplay == 0                  # Wurde Überzahl der Auswärtsmannschaft durch Zeitstrafe beendet?
            intTimePowerplayAway = intTimePowerplayAway + intTickerTime - intTimePowerplayChange
          end
        end
          
        if ticker_activity.home_or_away == 0
          intPowerplay = intPowerplay - 1
          if intPowerplay == 1                  # Ist Auswärtsmannschaft durch Rückkehr in Überzahl gekommen?
            intTimePowerplayChange = intTickerTime
          end
          if intPowerplay == 0                  # Wurde Überzahl der Heimmannschaft durch Zeitstrafe beendet?
            intTimePowerplayHome = intTimePowerplayHome + intTickerTime - intTimePowerplayChange
          end
        end
      end
    end

    intTimePowerplayHome = intTimePowerplayHome / 1000
    intTimePowerplayAway = intTimePowerplayHome / 1000

    # Falls eine Mannschaft zum Ende des Spiels in Überzahl ist
    if intPowerplay > 0
      intTimePowerplayHome = intTimePowerplayHome + (duration * 2 * 60) - intTimePowerplayChange
    end
    if intPowerplay < 0
      intTimePowerplayAway = intTimePowerplayAway + (duration * 2 * 60) - intTimePowerplayChange
    end

  # 28 => Titel Zeit in Überzahl
    game_stat_array.push(I18n.t('basic.powerplay'))
    # 29 => Zeit Heim
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimePowerplayHome))
    # 30 => Zeit Auswärts
    game_stat_array.push(TickerActivity.convert_seconds_to_time(intTimePowerplayAway))
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Zeit hatte
    max_width = intTimePowerplayHome
    if intTimePowerplayAway > intTimePowerplayHome
      max_width = intTimePowerplayAway
    end
    array_length = game_stat_array.count
    # 31 - 34 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * intTimePowerplayHome / max_width))
      game_stat_array.push(row_width * intTimePowerplayHome / max_width)
      game_stat_array.push(row_width * intTimePowerplayAway / max_width)
      game_stat_array.push(row_width - (row_width * intTimePowerplayAway / max_width))
    end
  # 35 => Titel Tore in Überzahl
    game_stat_array.push(I18n.t('basic.goals_powerplay'))
    # 36 => Überzahl Heim
    game_stat_array.push(intGoalsPowerplayHome)
    # 37 => Überzahl Auswärts
    game_stat_array.push(intGoalsPowerplayAway)
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Überzahl hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 38 - 41 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end
  # 42 => Titel Unterzahl
    game_stat_array.push(I18n.t('basic.goals_shorthanded'))
    # 43 => Unterzahl Heim
    game_stat_array.push(intGoalsShorthandedHome)
    # 44 => Unterzahl Auswärts
    game_stat_array.push(intGoalsShorthandedAway)
    # Ermitteln, ob die Heim- oder Auswärtsmannschaft mehr Unterzahl hatte
    array_length = game_stat_array.count
    max_width = game_stat_array[array_length - 2]
    if game_stat_array[array_length - 1] > game_stat_array[array_length - 2]
      max_width = game_stat_array[array_length - 1]
    end
    array_length = game_stat_array.count
    # 45 - 48 => Breite der Balken berechnen
    if max_width == 0
      game_stat_array.push(row_width)
      game_stat_array.push(0)
      game_stat_array.push(0)
      game_stat_array.push(row_width)
    else
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 2] / max_width))
      game_stat_array.push(row_width * game_stat_array[array_length - 2] / max_width)
      game_stat_array.push(row_width * game_stat_array[array_length - 1] / max_width)
      game_stat_array.push(row_width - (row_width * game_stat_array[array_length - 1] / max_width))
    end


    return game_stat_array

  end

  def get_player_stat(playerID, home_or_away)

    player_stat_array = Array.new
    stat_hash = Hash.new
    stat_overall_hash = Hash.new
    
    row_width = 400
    duration = 1800
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end
    if home_or_away == '1'
      team_id = self.team_home_id
    end
    if home_or_away == '0'
      team_id = self.team_away_id
    end
    status = 0
    time_in = 0
    time = 0
    plus_minus = 0
    if home_or_away == '1'
      team_plus_minus = count_team_goals(self.team_home_id) - count_team_goals(self.team_away_id)
    else
      team_plus_minus = count_team_goals(self.team_away_id) - count_team_goals(self.team_home_id)
    end

    #
    # Spielzeit einfügen
    #
    self.ticker_activities.each do |ticker_activity|

      # Überprüfen, ob es eine Aktion des Spielers ist
      if playerID == ticker_activity.player_id.to_s
        # Wurde Spieler eingewechselt?
        if ticker_activity.activity_id == 10501 || ticker_activity.activity_id == 10503
          if status == 0
            time_in = ticker_activity.time
          end
          status = 1
        end
        
        # Wurde Spieler ausgewechselt?
        if ticker_activity.activity_id == 10502 || ticker_activity.activity_id == 10401 || 
           ticker_activity.activity_id == 10402 || ticker_activity.activity_id == 10403
          if status == 1
            time = time + ticker_activity.time - time_in
            status = 0
          end
        end
      else
        # ToDo
        # Falls es zwar keine Aktion des Spielers ist, aber es eine Einwechselung
        # ist und der zu prüfende Spieler gerade eingewechselt ist, prüfe, ob 
        # es sich um eine Mannschaftsaufstellung mit sieben Spielern handelt 
        # und ob das Ticker Ereignis noch nicht abgefragt wurde
        # Falls ja: Wechsel den Spieler aus.
        # Siehe Android-Projekt HelperSQL ab Zeile 1956
      end

      # Falls ein Tor geworfen wurde und Spieler aktiv war, ändere Plus / Minus Statistik
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102
        if status == 1
          ticker_home_or_away = ticker_activity.home_or_away
          if ticker_home_or_away == home_or_away.to_i
            plus_minus = plus_minus + 1
          else
            plus_minus = plus_minus - 1
          end
        end
      end
    end

    time = time /1000
    time_in = time_in / 1000

    # Falls der Spieler auch am Ende des Spiels noch eingewechselt war, 
    # addiere die restliche Spielzeit zur Gesamtspielzeit.
    if status == 1
      time = time + (duration * 2 * 60) - time_in
    end

    # Spielzeit und +/- eintragen
    if time > 0
      # Titel Spielzeit
      player_stat_array.push(I18n.t('basic.playing_time'))
      # Wert
      player_stat_array.push(TickerActivity.convert_seconds_to_time(time))
      # Breite der Balken berechnen
      player_stat_array.push(row_width * time / (duration * 2 * 60))
      player_stat_array.push(row_width - (row_width * time / (duration * 2 * 60)))

      # Titel Plus Minus
      player_stat_array.push(I18n.t('basic.plus_minus'))
      # Wert
      player_stat_array.push(plus_minus.to_s)
      # Breite der Balken berechnen
      # player_stat_array.push(row_width * plus_minus / team_plus_minus)
      # player_stat_array.push(row_width - (row_width * plus_minus / team_plus_minus))
      player_stat_array.push(0)
      player_stat_array.push(0)
    end

    #
    # Sonstige Statistiken zu dem Spieler einfügen
    #
    team_attempts = count_team_goals(team_id) + count_team_miss(team_id)
    team_attempts_7m = count_team_activity(10101, team_id) + count_team_activity(10151, team_id)
    team_attempts_fb = count_team_activity(10102, team_id) + count_team_activity(10152, team_id)
    team_gk_throws = count_team_saves(team_id) + count_team_goal_againsts(team_id)
    team_gk_7m_throws = count_team_activity(10201, team_id) + count_team_activity(10251, team_id)
    team_gk_fb_throws = count_team_activity(10202, team_id) + count_team_activity(10252, team_id)

    stat_overall_hash[10100] = count_team_goals(team_id)
    stat_overall_hash[10101] = count_team_activity(10101, team_id)
    stat_overall_hash[10102] = count_team_activity(10102, team_id)
    stat_overall_hash[10200] = count_team_saves(team_id)
    stat_overall_hash[10201] = count_team_activity(10201, team_id)
    stat_overall_hash[10202] = count_team_activity(10201, team_id)

    stat_overall_hash[10160] = count_team_activity(10160, team_id)
    stat_overall_hash[10161] = count_team_activity(10161, team_id)
    stat_overall_hash[10171] = count_team_activity(10171, team_id)
    stat_overall_hash[10170] = count_team_activity(10170, team_id)
    stat_overall_hash[10173] = count_team_activity(10173, team_id)
    stat_overall_hash[10172] = count_team_activity(10172, team_id)
    stat_overall_hash[10174] = count_team_activity(10174, team_id)

    stat_overall_hash[10300] = count_team_activity(10300, team_id)
    stat_overall_hash[10301] = count_team_activity(10301, team_id)
    stat_overall_hash[10302] = count_team_activity(10302, team_id)
    stat_overall_hash[10303] = count_team_activity(10303, team_id)
    stat_overall_hash[10304] = count_team_activity(10304, team_id)
    stat_overall_hash[10305] = count_team_activity(10305, team_id)
    stat_overall_hash[10306] = count_team_activity(10306, team_id)
    stat_overall_hash[10307] = count_team_activity(10307, team_id)
    stat_overall_hash[10308] = count_team_activity(10308, team_id)

    stat_overall_hash[10400] = count_team_activity(10400, team_id)
    stat_overall_hash[10401] = count_team_activity(10401, team_id)
    stat_overall_hash[10402] = count_team_activity(10402, team_id)
    stat_overall_hash[10403] = count_team_activity(10403, team_id)

    stat_hash[10100] = I18n.t('basic.goals_overall')
    stat_hash[10101] = I18n.t('basic.seven_goals')
    stat_hash[10102] = I18n.t('basic.fb_goals')
    stat_hash[10200] = I18n.t('basic.gk_save')
    stat_hash[10201] = I18n.t('basic.seven_save')
    stat_hash[10202] = I18n.t('basic.fb_save')

    stat_hash[10160] = I18n.t('basic.assist_goal')
    stat_hash[10161] = I18n.t('basic.assists')
    stat_hash[10171] = I18n.t('basic.defense_successful')
    stat_hash[10170] = I18n.t('basic.defensive_error')
    stat_hash[10173] = I18n.t('basic.block_successful')
    stat_hash[10172] = I18n.t('basic.block_error')
    stat_hash[10174] = I18n.t('basic.fouls')

    stat_hash[10300] = I18n.t('basic.tech_faults')
    stat_hash[10301] = I18n.t('basic.Fehlpass')
    stat_hash[10302] = I18n.t('basic.steps')
    stat_hash[10303] = I18n.t('basic.three_seconds_rule')
    stat_hash[10304] = I18n.t('basic.Doppeldribbel')
    stat_hash[10305] = I18n.t('basic.Fuss')
    stat_hash[10306] = I18n.t('basic.Zeitspiel')
    stat_hash[10307] = I18n.t('basic.Kreis')
    stat_hash[10308] = I18n.t('basic.Stuermerfoul')

    stat_hash[10400] = I18n.t('basic.yellow_cards')
    stat_hash[10401] = I18n.t('basic.two_minutes')
    stat_hash[10402] = I18n.t('basic.two_plus_two')
    stat_hash[10403] = I18n.t('basic.red_cards')

    stat_hash.each do |key, player_text|
      activity_id = "#{key}".to_i
      stat_overall = stat_overall_hash[activity_id]
      stat_player = nil

      # Tore, wenn sie 0, aber Fehlwürfe, anzeigen, bei den aderen Aktionen nicht anzeigen, wenn 0
      if activity_id == 10100 || activity_id == 10101 || activity_id == 10102
        if activity_id == 10100
          if count_player_goals(playerID) + count_player_miss(playerID) > 0
            stat_player = count_player_goals(playerID)
          end
        else
          attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
          if attempts > 0
            stat_player = count_player_activities(playerID, activity_id)
          end
        end
      else
        # Kontrolle auch für den Torwart
        if activity_id == 10200 || activity_id == 10201 || activity_id == 10202
          if activity_id == 10200
            if count_gk_saves(playerID) + count_gk_goal_againsts(playerID) > 0
              stat_player = count_gk_saves(playerID)
            end
          else
            attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
            if attempts > 0
              stat_player = count_player_activities(playerID, activity_id)
            end
          end
        else
          if count_player_activities(playerID, activity_id) > 0
            stat_player = count_player_activities(playerID, activity_id)
          end
        end
      end

      if stat_player != nil

        # Titel
        player_stat_array.push(player_text)
        # Wert
        player_stat_array.push(stat_player)
        # Breite der Balken berechnen
        if stat_overall > 0
          player_stat_array.push(row_width * stat_player / stat_overall)
          player_stat_array.push(row_width - (row_width * stat_player / stat_overall))
        else
          player_stat_array.push(0)
          player_stat_array.push(row_width)
        end

        # Falls es sich um ein Tor handelt, trage noch die Versuche und Quote ein
        if activity_id == 10100
          player_stat_array.push(I18n.t('basic.attempts'))
          attempts = self.count_player_goals(playerID) + self.count_player_miss(playerID)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_attempts)
          player_stat_array.push(row_width - (row_width * attempts / team_attempts))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = player_effective_goals(playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end
        if activity_id == 10101
          player_stat_array.push(I18n.t('basic.seven_attempts'))
          attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_attempts_7m)
          player_stat_array.push(row_width - (row_width * attempts / team_attempts_7m))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = player_effective(activity_id, playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end
        if activity_id == 10102
          player_stat_array.push(I18n.t('basic.fb_attempts'))
          attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_attempts_fb)
          player_stat_array.push(row_width - (row_width * attempts / team_attempts_fb))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = player_effective(activity_id, playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end

        # Falls es sich um die Aktion eines Torwarts handelt, trage noch die Versuche und Quote ein
        if activity_id == 10200
          player_stat_array.push(I18n.t('basic.throws'))
          attempts = self.count_gk_saves(playerID) + self.count_gk_goal_againsts(playerID)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_gk_throws)
          player_stat_array.push(row_width - (row_width * attempts / team_gk_throws))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = gk_effective_saves(playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end
        if activity_id == 10201
          player_stat_array.push(I18n.t('basic.seven_throws'))
          attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_gk_7m_throws)
          player_stat_array.push(row_width - (row_width * attempts / team_gk_7m_throws))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = player_effective(activity_id, playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end
        if activity_id == 10202
          player_stat_array.push(I18n.t('basic.fb_throws'))
          attempts = self.count_player_activities(playerID, activity_id) + self.count_player_activities(playerID, activity_id + 50)
          player_stat_array.push(attempts)
          player_stat_array.push(row_width * attempts / team_gk_fb_throws)
          player_stat_array.push(row_width - (row_width * attempts / team_gk_fb_throws))

          player_stat_array.push(I18n.t('basic.percentage'))
          percent_player = player_effective(activity_id, playerID)
          percentstring = percent_player.to_s
          string = percentstring + "%"
          player_stat_array.push(string)
          player_stat_array.push(row_width * percent_player / 100)
          player_stat_array.push(row_width - (row_width * percent_player / 100))
        end
      end
    end

# ToDo => Statistik über die Art der Würfe einfügen

    return player_stat_array

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
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ? AND time <= ?", 10100, 10101, 10102, teamID, time).count
  end

  # Tore eines Teams
  def count_team_goals(teamID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ?", 10100, 10101, 10102, teamID).count
  end

  # Fehlwürfe eines Teams
  def count_team_miss(teamID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ?", 10150, 10151, 10152, teamID).count
  end

  # Paraden eines Teams
  def count_team_saves(teamID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ?", 10200, 10201, 10202, teamID).count
  end

  # Gegentore eines Teams
  def count_team_goal_againsts(teamID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ?", 10250, 10251, 10252, teamID).count
  end

  # Quote eines Teams
  def team_effective(teamID, gameID)
    attempts = self.count_team_goals(teamID) + self.count_team_miss(teamID)
    if attempts > 0
      effective = self.count_team_goals(teamID) * 100 / attempts
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
  def count_player_goals(playerID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ?", 10100, 10101, 10102, playerID).count
  end
  
  # Fehlwürfe eines Spielers
  def count_player_miss(playerID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ?", 10150, 10151, 10152, playerID).count
  end

  # Paraden eines Torwarts
  def count_gk_saves(playerID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ?", 10200, 10201, 10202, playerID).count
  end

  # Gegentore eines Torwarts
  def count_gk_goal_againsts(playerID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ?", 10250, 10251, 10252, playerID).count
  end

  # Effektivität eines Spielers
  def player_effective_goals(playerID)
    attempts = self.count_player_goals(playerID) + self.count_player_miss(playerID)
    if attempts > 0
      effective = self.count_player_goals(playerID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  def gk_effective_saves(playerID)
    attempts = self.count_gk_saves(playerID) + self.count_gk_goal_againsts(playerID)
    if attempts > 0
      effective = self.count_gk_saves(playerID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  def player_effective(activityID, playerID)
    attempts = self.count_player_activities(playerID, activityID) + self.count_player_activities(playerID, activityID + 50)
    if attempts > 0
      effective = self.count_player_activities(playerID, activityID) * 100 / attempts
    else
      effective = 0
    end
    return effective
  end

  # Anzahl Aktivitäten eines Spielers
  def count_player_activities(playerID, activityID)
    self.ticker_activities.where("activity_id = ? AND player_id = ?", activityID, playerID).count
  end

  #
  #
  # Betsen Torschützen ermitteln
  #
  #

  def get_top_scorer_hash(gameID)
    player_hash = Hash.new

    self.players.each do |player|

      player_hash[player.id] = self.count_player_goals(player.id)

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

      player_goal = self.count_player_goals(player.id)
      player_miss = self.count_player_miss(player.id)
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
      duration_halftime = 30
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

    time_lead_home = time_lead_home / 1000
    time_lead_away = time_lead_away / 1000
    time_lead_change = time_lead_change / 1000

    # Restzeit bis zum Ende des Spiels ermitteln
    # Die Heimmannschaft lag bis zum Ende des Spiels in Führung
    if goals_home - goals_away > 0
      time_lead_home = time_lead_home + (duration_halftime * 2 * 60) - time_lead_change
    end
    # Die Auswärtsmannschaft lag bis zum Ende des Spiels in Führung
    if goals_home - goals_away < 0
      time_lead_away = time_lead_away + (duration_halftime * 2 * 60) - time_lead_change
    end
    # Zum Ende des Spiels Stand es Unentschieden
    if goals_home == goals_away
      time_draw = time_draw + (duration_halftime * 2 * 60) - time_lead_change
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

  #
  #
  # Funktionen
  #
  #

  def convert_game_date(date)

    date = DateTime.parse(date)
    result = date.strftime('%a %b %d %H:%M:%S %Z %Y')

    return result

  end

end


