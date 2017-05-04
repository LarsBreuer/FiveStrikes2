class Game < ActiveRecord::Base

  # ToDo => Eventuell doch Verweis auf Team Home und Team Away einrichten, statt nur auf die ID zu verweisen
  has_many :ticker_activities, :dependent => :destroy, :order => 'time ASC'
  has_many :ticker_events, :dependent => :delete_all, :order => 'time DESC'
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  require 'date'
  include Math

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

  def get_team_type_by_team_id(team_id)
    team_type(Team.find(:first, :conditions => [ "id = ?", team_id ]).team_type_id)
  end

# ToDo => Diese Funktion findet sich auch in team.rb wieder => vereinheitlichen

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

      if gender_id == 1
        gender = "m"
      end
      if gender_id == 2
        gender = "w"
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
        team_type = gender + level
      end
      if age_id > 1
        team_type = gender + age + level + " "
      end
    end

    return team_type

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
        unless player_array.include?(player)
          player_array.push(player)
        end
      end
    end

    return player_array

  end

  def get_player_away()

    player_array = Array.new

    self.players.each do |player|
      if player.team_id == self.team_away_id
        unless player_array.include?(player)
          player_array.push(player)
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

  def get_game_main_stat()

    game_stat_main_array = Array.new
    params_array = Array.new
    goals = self.count_team_goals(self.team_home_id) + self.count_team_goals(self.team_away_id)

    # Tore
    game_stat_main_array.push(count_team_goals(self.team_home_id))
    game_stat_main_array.push(count_team_goals(self.team_away_id))

    # Nur wenn im Spiel ein Tor gefallen ist den besten Torschützen und den besten Torwart anzeigen
    if goals > 0
      # Bester Torschütze
      params_array = self.get_top_scorer(self.id)
      game_stat_main_array.push(params_array[0])
      game_stat_main_array.push(params_array[1])

      # Bester Torwart
      params_array = self.get_top_goalie(self.id)
      game_stat_main_array.push(params_array[0])
      game_stat_main_array.push(params_array[1])

    else
      game_stat_main_array.push("")
      game_stat_main_array.push("")
      game_stat_main_array.push("")
      game_stat_main_array.push("")
    end

    # Spielverlauf eingeben
    params_array = self.get_game_history(54, "Overview")
    i=0
    while i < 40 do
      game_stat_main_array.push(params_array[i])
      i += 1
    end

    # Längste Führung
    params_array = self.get_team_lead(self.id)
    game_stat_main_array.push(params_array[0])
    game_stat_main_array.push(params_array[1])

    # Höchste Führung
    params_array = self.get_max_team_lead()
    game_stat_main_array.push(params_array[0])
    game_stat_main_array.push(params_array[1])

    # Mannschaft Effektivität
    game_stat_main_array.push(team_effective(self.team_home_id, self.id))
    game_stat_main_array.push(team_effective(self.team_away_id, self.id))

    # Fairste Mannschaft
    params_array = self.get_team_penalty(self.id)
    game_stat_main_array.push(params_array[0])
    game_stat_main_array.push(params_array[1])
    game_stat_main_array.push(params_array[2])
    game_stat_main_array.push(params_array[3])

    # Nur wenn im Spiel ein Tor gefallen ist den besten Torschützen und den besten Torwart anzeigen
    if goals > 0
      # Spieler Effektivität
      params_array = self.get_top_effective(self.id)
      game_stat_main_array.push(params_array[0])
      game_stat_main_array.push(params_array[1])
    else
      game_stat_main_array.push("")
      game_stat_main_array.push("")
    end

    return game_stat_main_array

  end

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
    duration = 30
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
    intChangePossessionTime = intChangePossessionTime / 1000

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
    duration = 30
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
    intTimeLeadChange = intTimeLeadChange / 1000

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

  def get_game_history(row_width, source)

    game_stat_array = Array.new
    max_lead_array = Array.new
    game_stat_away = Array.new

    duration = 30
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end

    max_lead_array = self.get_max_team_lead
    max_width = max_lead_array[0]

    i = 1

    if source == "Statistic"

      time_step = 5
      intervall = duration * 2 / time_step

      while i <= intervall do
        # 0 => Titel Spielstand zur x. Minute
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
    end
    if source == "Overview"

      intervall = 20
      time_step = duration * 2 / intervall

      while i <= intervall do

        # Tore Heim und Auswärts ermitteln
        goals_home = count_team_goals_time(self.team_home_id, time_step * i)
        goals_away = count_team_goals_time(self.team_away_id, time_step * i)

        # Führung Heim oder Auswärts ermitteln
        diff_home = 0
        diff_away = 0
        if goals_home > goals_away
          diff_home = goals_home - goals_away
        end
        if goals_away > goals_home
          diff_away = goals_away - goals_home
        end

        # Breite des Balken entsprechend der Führung ermitteln
        if max_width == 0
          game_stat_array.push(0)
          game_stat_away.push(0)
        else
          game_stat_array.push(row_width * diff_home / max_width)
          game_stat_away.push(row_width * diff_away / max_width)
        end
        i += 1

      end

      i = 1

      while i <= intervall do

        # Daten für die Auswärtsmannschaft eingeben
        game_stat_array.push(game_stat_away[i-1])
        i += 1

      end
    end

    return game_stat_array

  end

  def get_max_team_lead()

    team_lead_array = Array.new

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

    if intMaxLeadHome > intMaxLeadAway
      team_lead_array.push(intMaxLeadHome)
      team_lead_array.push(self.get_club_name_short_by_team_id(self.team_home_id))
    else
      team_lead_array.push(intMaxLeadAway)
      team_lead_array.push(self.get_club_name_short_by_team_id(self.team_away_id))
    end

    return team_lead_array

  end

  def get_game_penalty()

    game_stat_array = Array.new
    row_width = 300
    duration = 30
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
    intTimePowerplayChange = intTimePowerplayChange / 1000

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
    duration = 30
    if self.duration_halftime != nil
      duration = self.duration_halftime
    end
    if home_or_away == '1'
      team_id = self.team_home_id
    end
    if home_or_away == '0'
      team_id = self.team_away_id
    end
    player_status = 0
    time_in = 0
    time = 0
    plus_minus = 0
    if home_or_away == '1'
      team_plus_minus = count_team_goals(self.team_home_id) - count_team_goals(self.team_away_id)
    else
      team_plus_minus = count_team_goals(self.team_away_id) - count_team_goals(self.team_home_id)
    end
    last_ticker_event_id = -1
    ticker_lineup_id = 0

    #
    # Spielzeit einfügen
    #
    self.ticker_activities.each do |ticker_activity|

      ticker_event_id = ticker_activity.ticker_event_id_local

      # Überprüfen, ob es eine Aktion des Spielers ist
      if playerID == ticker_activity.player_id.to_s
        # Wurde Spieler eingewechselt?
        if ticker_activity.activity_id == 10501 || ticker_activity.activity_id == 10503
          if player_status == 0
            time_in = ticker_activity.time
          end
          player_status = 1
        end

        # Wurde Spieler ausgewechselt?
        if ticker_activity.activity_id == 10502 || ticker_activity.activity_id == 10401 ||
           ticker_activity.activity_id == 10402 || ticker_activity.activity_id == 10403
          if player_status == 1
            time = time + ticker_activity.time - time_in
            player_status = 0
          end
        end
      else

        # Falls es zwar keine Aktion des Spielers, aber eine Einwechselung
        # ist und der zu prüfende Spieler gerade eingewechselt ist, prüfe, ob
        # es sich um eine Mannschaftsaufstellung mit sieben Spielern handelt
        # und ob das Ticker Ereignis noch nicht abgefragt wurde
        # Falls ja: Wechsel den Spieler aus.

        if ticker_activity.activity_id == 10501 && player_status == 1 && ticker_event_id != last_ticker_event_id

          ticker_activities_sub_in = self.ticker_activities.where("ticker_event_id_local = ? AND activity_id = ?", ticker_event_id, 10501)

          if ticker_activities_sub_in.count == 7

            # Überprüfe, ob der Spieler Teil der Mannschaftsaufstellung ist
            player_in = false
            # Alle Tickermeldungen des Events abfragen und mit der Spieler ID vergleichen
            ticker_activities_sub_in.each do |ticker_activity_sub_in|
              ticker_lineup_id = ticker_activity_sub_in.id
              if ticker_lineup_id != nil
                if ticker_lineup_id == playerID
                  player_in = true
                end
              end
            end

            # Ticker Event ID speichern, damit diese nicht noch einmal abgefragt wird
            last_ticker_event_id = ticker_event_id

            # Falls nicht, also falls sieben Spieler eingewechselt wurden und der
            # zu prüfende Spieler nicht dabei war, wurde der zu prüfende
            # Spieler ausgewechselt.
            if player_in == false

              time = time + ticker_activity.time - time_in
              player_status = 0

            end
          end
        end
      end

      # Falls ein Tor geworfen wurde und Spieler aktiv war, ändere Plus / Minus Statistik
      if ticker_activity.activity_id == 10100 || ticker_activity.activity_id == 10101 || ticker_activity.activity_id == 10102
        if player_status == 1
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
    if player_status == 1
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

  def get_player_field_matrix(playerID, position_control, x_click, y_click, goal_area)
    
    player_field_matrix = Array.new
    player_stat_goal_array = self.get_player_stat_goal(playerID, position_control, x_click, y_click, goal_area)
    player = self.players.where("player_id = ?", playerID).first

    if player.player_position_first == '1001'
      goalkeeper = true
    else
      goalkeeper = false
    end

    if x_click == nil && y_click == nil && position_control == nil   # Farbige Felder festlegen, falls keine konkrete Position ausgewählt

      # Aufteilung des Spielfeld-Arrays
      # 0-149 => Farbe des Bereichs auf dem Spielfeld (15x10 Matrix)
      # 150-170 => Beschriftung des Spielfelds nach Wurfpositionen
      # 171- => Färbung und Beschriftung der Wurfecke

      for x_counter in 1..15
        for y_counter in 1..10

          plus = 0
          minus = 0
          attempts = 0
          percent = 0

          if goalkeeper == true
                # 1-150 => Feldtor
                # 151-300 => 7m-Tor
                # 301-450 => Tempogegenstoss-Tor
                # Danach jeweils in 150-Schritten für Fehlwurf, Gehalten und Torwart-Gegentor
            plus = player_stat_goal_array[900 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[1050 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[1200 + x_counter + ((y_counter - 1) * 15)]
            minus = player_stat_goal_array[1350 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[1500 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[1650 + x_counter + ((y_counter - 1) * 15)]
            attempts = plus + minus
            percent = plus * 100 / attempts if attempts > 0
          
          else
              
            plus = player_stat_goal_array[x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[150 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[300 + x_counter + ((y_counter - 1) * 15)]
            minus = player_stat_goal_array[450 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[600 + x_counter + ((y_counter - 1) * 15)] + player_stat_goal_array[750 + x_counter + ((y_counter - 1) * 15)]
            attempts = plus + minus;
            percent = plus * 100 / attempts if attempts > 0
              
          end

          if attempts > 0
            if goalkeeper == true
              player_field_matrix.push(1) if percent <= 25
              player_field_matrix.push(2) if percent > 25 && percent < 40
              player_field_matrix.push(3) if percent >= 40
            else
              player_field_matrix.push(1) if percent <= 33
              player_field_matrix.push(2) if percent > 33 && percent < 66
              player_field_matrix.push(3) if percent >= 66
            end
          else
            player_field_matrix.push(0)
          end

        end
      end

      # Wurfposition beschriften

      for x_counter in 0..7

        if goalkeeper == true
          plus = player_stat_goal_array[2089 + x_counter] + player_stat_goal_array[2097 + x_counter] + player_stat_goal_array[2105 + x_counter]
          minus = player_stat_goal_array[2113 + x_counter] + 
              player_stat_goal_array[2121 + x_counter] + 
              player_stat_goal_array[2129 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
            
        else
        
          plus = player_stat_goal_array[2041 + x_counter] + player_stat_goal_array[2049 + x_counter] + player_stat_goal_array[2057 + x_counter]
          minus = player_stat_goal_array[2065 + x_counter] + player_stat_goal_array[2073 + x_counter] + player_stat_goal_array[2081 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
            
        end

        if attempts > 0
          player_field_matrix.push(plus)
          player_field_matrix.push(attempts)
          player_field_matrix.push(percent)
        else
          player_field_matrix.push(0)
          player_field_matrix.push(0)
          player_field_matrix.push(0)
        end
      end

      # Wurfecke eingeben
      for x_counter in 0..19

        if goalkeeper == true
          plus = player_stat_goal_array[1921 + x_counter] + player_stat_goal_array[1941 + x_counter] + player_stat_goal_array[1961 + x_counter]
          minus = player_stat_goal_array[1981 + x_counter] + 
              player_stat_goal_array[2001 + x_counter] + 
              player_stat_goal_array[2021 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
            
        else
        
          plus = player_stat_goal_array[1801 + x_counter] + player_stat_goal_array[1821 + x_counter] + player_stat_goal_array[1841 + x_counter]
          minus = player_stat_goal_array[1861 + x_counter] + player_stat_goal_array[1881 + x_counter] + player_stat_goal_array[1901 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
            
        end

        if attempts > 0
          player_field_matrix.push(plus)
          player_field_matrix.push(attempts)
          player_field_matrix.push(percent)
        else
          player_field_matrix.push(0)
          player_field_matrix.push(0)
          player_field_matrix.push(0)
        end

      end

    else      # Falls eine bestimmte Position ausgewählt wurde

      for x_counter in 0..11

        player_field_matrix.push(player_stat_goal_array[2137 + x_counter])

      end

      # Wurfecke eingeben
      for x_counter in 0..19

        if goalkeeper == true
          plus = player_stat_goal_array[1921 + x_counter] + player_stat_goal_array[1941 + x_counter] + player_stat_goal_array[1961 + x_counter]
          minus = player_stat_goal_array[1981 + x_counter] + 
              player_stat_goal_array[2001 + x_counter] + 
              player_stat_goal_array[2021 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
        else
          plus = player_stat_goal_array[1801 + x_counter] + player_stat_goal_array[1821 + x_counter] + player_stat_goal_array[1841 + x_counter]
          minus = player_stat_goal_array[1861 + x_counter] + player_stat_goal_array[1881 + x_counter] + player_stat_goal_array[1901 + x_counter]
          attempts = plus + minus
          percent = plus * 100 / attempts if (attempts > 0) 
        end

        if attempts > 0
          player_field_matrix.push(plus)
          player_field_matrix.push(attempts)
          player_field_matrix.push(percent)
        else
          player_field_matrix.push(0)
          player_field_matrix.push(0)
          player_field_matrix.push(0)
        end
      end

      player_field_matrix.push(player_stat_goal_array[2149])
      player_field_matrix.push(player_stat_goal_array[2150])
      player_field_matrix.push(player_stat_goal_array[2151])

    end

    return player_field_matrix
  end

  def player_ticker(playerID)
puts "player_ticker aufgerufen"
    player_ticker_array = Array.new
    
    ticker = self.ticker_activities.where("player_id = ?", playerID)

    ticker.each do |ticker_activity|

      player_ticker_array.push(TickerActivity.convert_seconds_to_time(ticker_activity.time / 1000))
      player_ticker_array.push(TickerActivity.convert_activity_id_to_activity(ticker_activity.activity_id))

    end

    return player_ticker_array

  end

  def player_ticker_length(playerID)
    return ticker = self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ?) 
                                   AND player_id = ?", 
                                   10100, 10101, 10102, 10150, 10151, 10152, 10200, 10201, 10202, 10250, 10251, 10252, playerID).size
  end

  def get_player_stat_goal(playerID, position_control, x_click, y_click, goal_area)

    # Aufteilung des Spieler-Statistik Arrays
    # 1-1800 => Position des Wurfs auf dem Spielfel (15x10 Matrix)
      # 1-150 => Feldtor
      # 151-300 => 7m-Tor
      # 301-450 => Tempogegenstoss-Tor
      # Danach jeweils in 150-Schritten für Fehlwurf, Gehalten und Torwart-Gegentor
    # 1801-2040 => Wurfecke, ansonsten die Schritte wie oben
    # 2041-2136 => Position des Wurfs gemessen an der Spielerposition (Linksaußen, Halblinks Nachbereich, Halblinks Fern etc.)
    # 2137-2148 => Würfe von einer bestimmten Position aus
    # 2149-2150 => x- und y-Koordinate bei Wurffolge
    # 2151 => Beschriftung bei Wurffolge
    
    player_stat_goal_array = Array.new(2152, 0)
    bool_distance = false
    click_distance = 0
    max_distance = 50
    if x_click != nil && y_click != nil
      bool_distance = true
      x_click = x_click.to_i * 200 / 350
      y_click = (y_click.to_i - (10 * 228 / 130)) * 120 / 228
    end
    if position_control != nil
      position_control = position_control.to_i
    end
    
    position_counter = 0

    if goal_area == nil
      ticker = self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ?) 
                                   AND player_id = ?", 
                                   10100, 10101, 10102, 10150, 10151, 10152, 10200, 10201, 10202, 10250, 10251, 10252, playerID)
    else
      ticker = self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ? OR 
                                   activity_id = ? OR activity_id = ? OR activity_id = ?) 
                                   AND player_id = ? AND goal_area = ?", 
                                   10100, 10101, 10102, 10150, 10151, 10152, 10200, 10201, 10202, 10250, 10251, 10252, playerID, goal_area)
    end

    ticker.each do |ticker_activity|

      # Abfrage, ob nur eine bestimmter Wurf abgefragt werden soll oder alle Würfe abgefragt werden sollen
      if position_control == nil || position_control == position_counter

        ticker_activity_id = ticker_activity.activity_id

        # Wurftyp ermitteln
        # Beispiel: field_position_id = 0 wenn es sich um Torwurf handelt 
        field_position_id = 0 if ticker_activity_id == 10100
        field_position_id = 1 if ticker_activity_id == 10101
        field_position_id = 2 if ticker_activity_id == 10102
        field_position_id = 3 if ticker_activity_id == 10150
        field_position_id = 4 if ticker_activity_id == 10151
        field_position_id = 5 if ticker_activity_id == 10152
        field_position_id = 6 if ticker_activity_id == 10200
        field_position_id = 7 if ticker_activity_id == 10201
        field_position_id = 8 if ticker_activity_id == 10202
        field_position_id = 9 if ticker_activity_id == 10250
        field_position_id = 10 if ticker_activity_id == 10251
        field_position_id = 11 if ticker_activity_id == 10252

        # Statistiken Wurfposition berechnen
        # Koordinaten abfragen
          
        x_coord_original = ticker_activity.field_position_x
        y_coord_original = ticker_activity.field_position_y

        if position_control != nil
          bool_distance = true
          x_click = x_coord_original 
          y_click = y_coord_original
          player_stat_goal_array[2149] = x_click * 350 / 200
          player_stat_goal_array[2150] = y_click * 228 / 120 + (10 * 228 / 130)
          player_stat_goal_array[2151] = TickerActivity.convert_seconds_to_time(ticker_activity.time / 1000).to_s + " " + I18n.t('basic.minutes_short') + " " + TickerActivity.convert_activity_id_to_activity(ticker_activity.activity_id)
        end

        if x_coord_original != nil && y_coord_original != nil
            
          # Wurf auf dem Spielfeld zuordnen
          # Abfrage, ob eine bestimmte Spielposition, oder ob alle Positionen abgefragt werden sollen 
          if bool_distance == false     # Wenn kein fester Punkt angegeben wurde...

            # ... alle Positionen in die Auswertung einbeziehen
            x_coord_matrix = (x_coord_original * 3 / 40) + 1
            y_coord_matrix = (y_coord_original / 12) + 1

            if x_coord_matrix > 15 
              x_coord_matrix = 15
            end
            if y_coord_matrix > 10 
              y_coord_matrix = 10
            end

            for x_counter in -2..2
              for y_counter in -2..2

                x_matrix = x_coord_matrix + x_counter
                y_matrix = y_coord_matrix + y_counter
                
                if x_matrix >= 1 && x_matrix <= 15 && y_matrix >= 1 && y_matrix <=10

                  # Konkrete Matrix bestimmt sich nach dem Wurftyp, der x-Koordinate und der y-Koordinate
                  matrix_id = (field_position_id * 150) + (x_matrix) + ((y_matrix - 1) * 15)

                  if player_stat_goal_array[matrix_id] != nil
                    player_stat_goal_array[matrix_id] = player_stat_goal_array[matrix_id] + 1
                  else
                    player_stat_goal_array[matrix_id] = 1
                  end
                  
                end
                  
              end
            end

            # ... Wurf einer Spielerposition zuordnen
            position = self.get_position(x_coord_original, y_coord_original)

            matrix_id = 2041 + field_position_id * 8 + position

            if player_stat_goal_array[matrix_id] != nil
              player_stat_goal_array[matrix_id] = player_stat_goal_array[matrix_id] + 1
            else
              player_stat_goal_array[matrix_id] = 1
            end

          else      # Wenn eine konkrete Position angegeben wurde
            
            click_distance = Math.sqrt((x_coord_original - x_click) ** 2 + (y_coord_original - y_click) ** 2)

            if click_distance <= max_distance
              matrix_id = 2137 + field_position_id
              player_stat_goal_array[matrix_id] = player_stat_goal_array[matrix_id] + 1
            end

          end
        end

        # Statistiken Wurfecke berechnen
        goal_area = ticker_activity.goal_area

        if goal_area != nil
          x_area = nil
          y_area = nil
          if goal_area == "uull"
            x_area = 0
            y_area = 0
          end
          if goal_area == "uul"
            x_area = 1
            y_area = 0
          end
          if goal_area == "uum"
            x_area = 2
            y_area = 0
          end
          if goal_area == "uur"
            x_area = 3
            y_area = 0
          end
          if goal_area == "uurr"
            x_area = 4
            y_area = 0
          end
          if goal_area == "ull"
            x_area = 0
            y_area = 1
          end
          if goal_area == "ul"
            x_area = 1
            y_area = 1
          end
          if goal_area == "um"
            x_area = 2
            y_area = 1
          end
          if goal_area == "ur"
            x_area = 3
            y_area = 1
          end
          if goal_area == "urr"
            x_area = 4
            y_area = 1
          end
          if goal_area == "mll"
            x_area = 0
            y_area = 2
          end
          if goal_area == "ml"
            x_area = 1
            y_area = 2
          end
          if goal_area == "mm"
            x_area = 2
            y_area = 2
          end
          if goal_area == "mr"
            x_area = 3
            y_area = 2
          end
          if goal_area == "mrr"
            x_area = 4
            y_area = 2
          end
          if goal_area == "lll"
            x_area = 0
            y_area = 3
          end
          if goal_area == "ll"
            x_area = 1
            y_area = 3
          end
          if goal_area == "lm"
            x_area = 2
            y_area = 3
          end
          if goal_area == "lr"
            x_area = 3
            y_area = 3
          end
          if goal_area == "lrr"
            x_area = 4
            y_area = 3
          end

          if x_area != nil && y_area != nil

            if (bool_distance == true && click_distance <= max_distance) || bool_distance == false
              matrix_id = (field_position_id * 20) + (x_area) + (y_area * 5) + 1801
              if player_stat_goal_array[matrix_id] != nil
                player_stat_goal_array[matrix_id] = player_stat_goal_array[matrix_id] + 1
              else
                player_stat_goal_array[matrix_id] = 1
              end
            end

          end
        end
      end

      position_counter = position_counter + 1

    end

    return player_stat_goal_array

  end

  def get_position(x_coord_original, y_coord_original)

    best_position = 0
    best_distance = 250
    position_x = Array.new
    position_y = Array.new

    position_x.push(20)
    position_x.push(34)
    position_x.push(54)
    position_x.push(100)
    position_x.push(100)
    position_x.push(164)
    position_x.push(144)
    position_x.push(180)

    position_y.push(30)
    position_y.push(94)
    position_y.push(69)
    position_y.push(99)
    position_y.push(69)
    position_y.push(94)
    position_y.push(69)
    position_y.push(30)

    for position in 0..7

      distance = Math.sqrt(((x_coord_original - position_x[position]) ** 2 ) +
                           ((y_coord_original - position_y[position]) ** 2))

      if distance < best_distance
        best_distance = distance
        best_position = position
      end

    end

    return best_position

  end

  #
  #
  # Tore / Aktionen zählen
  #
  #

  # Aktivitäten
  def count_game_activity()
    self.ticker_activities.count
  end

  def count_team_activity(activityID, teamID)
    self.ticker_activities.where(:activity_id => activityID, :team_id => teamID).count
  end

  # Tore zu einer Spielzeit
  def count_team_goals_time(teamID, time)
    time = time * 1000 * 60
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ? AND time <= ?", 10100, 10101, 10102, teamID, time).count
  end

  # Tore eines Teams
  def count_team_goals(teamID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ?", 10100, 10101, 10102, teamID).count
  end

  def total_goals
    self.ticker_activities.select {|ta| [10100, 10101, 10102].include?(ta.activity_id) and ta.team_id}.size
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

  def count_player_tech_faults(playerID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ? OR activity_id = ? OR activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ?", 10300, 10301, 10302, 10303, 10304, 10305, 10306, playerID).count
  end

  def count_player_two_minutes(playerID)
    two_minutes = self.ticker_activities.where("activity_id = ?  AND player_id = ?", 10401, playerID).count
    two_plus_two = self.ticker_activities.where("activity_id = ?  AND player_id = ?", 10402, playerID).count
    return two_minutes + (two_plus_two * 2)
  end

  def player_effective_goals_total(playerID)
    # Prüfung, ob Spieler Torwart oder Feldspieler ist
    if count_gk_saves(playerID) > count_player_goals(playerID)
      effective = self.gk_effective_saves(playerID)
      if effective > 0
        attempts = self.count_gk_saves(playerID) + self.count_gk_goal_againsts(playerID)
        str_effective = self.count_gk_saves(playerID).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    else
      effective = self.player_effective_goals(playerID)
      if effective > 0
        attempts = self.count_player_goals(playerID) + self.count_player_miss(playerID)
        str_effective = self.count_player_goals(playerID).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    end
    return str_effective
  end

  def player_effective_goals_7m(playerID)
    # Prüfung, ob Spieler Torwart oder Feldspieler ist
    if count_player_activities(playerID, 10201) > count_player_activities(playerID, 10101)
      effective = self.player_effective(10201, playerID)
      if effective > 0
        attempts = self.count_player_activities(playerID, 10201) + self.count_player_activities(playerID, 10251)
        str_effective = self.count_player_activities(playerID, 10201).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    else
      effective = self.player_effective(10101, playerID)
      if effective > 0
        attempts = self.count_player_activities(playerID, 10101) + self.count_player_activities(playerID, 10151)
        str_effective = self.count_player_activities(playerID, 10101).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    end
    return str_effective
  end

  def player_effective_goals_fb(playerID)
    # Prüfung, ob Spieler Torwart oder Feldspieler ist
    if count_player_activities(playerID, 10202) > count_player_activities(playerID, 10102)
      effective = self.player_effective(10202, playerID)
      if effective > 0
        attempts = self.count_player_activities(playerID, 10202) + self.count_player_activities(playerID, 10252)
        str_effective = self.count_player_activities(playerID, 10202).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    else
      effective = self.player_effective(10102, playerID)
      if effective > 0
        attempts = self.count_player_activities(playerID, 10102) + self.count_player_activities(playerID, 10152)
        str_effective = self.count_player_activities(playerID, 10102).to_s + " / " + attempts.to_s + " / " + effective.to_s + "%"
      else
        str_effective = "0"
      end
    end
    return str_effective
  end

  #
  #
  # Besten Torschützen / Torwart ermitteln
  #
  #

  def get_top_scorer_hash(home_or_away)
    player_hash = Hash.new

    self.players.each do |player|

      if home_or_away == "all"
        player_hash[player] = self.count_player_goals(player.id)
      end

      if home_or_away == "home"
        if player.team_id == self.team_home_id
          player_hash[player] = self.count_player_goals(player.id)
        end
      end

      if home_or_away == "away"
        if player.team_id == self.team_away_id
          player_hash[player] = self.count_player_goals(player.id)
        end
      end



    end

    player_hash = Hash[player_hash.sort_by{|k, v| v}.reverse]

    return player_hash

  end

  def get_top_scorer(gameID)

    top_scorer_array = Array.new

    goals = self.count_team_goals(self.team_home_id) + self.count_team_goals(self.team_away_id)

    if goals > 0
      player = self.get_top_scorer_hash("all").max_by{|k,v| v}[0]
      top_scorer_array.push(self.get_top_scorer_hash("all").max_by{|k,v| v}[1])
      top_scorer_array.push(player.player_surename)
      return top_scorer_array
    end
  end

  def get_top_goalie_hash(gameID)
    player_hash = Hash.new

    self.players.each do |player|

      player_hash[player.id] = self.gk_effective_saves(player.id)

    end

    return player_hash

  end

  def get_top_goalie(gameID)

    top_goalie_array = Array.new

    top_goalie_array.push(self.get_top_goalie_hash(gameID).max_by{|k,v| v}[1])
    playerID = self.get_top_goalie_hash(gameID).max_by{|k,v| v}[0]
    player = self.players.where("player_id = ?", playerID).first
    top_goalie_array.push(player.player_surename)

    return top_goalie_array

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

  def get_top_effective(gameID)

    top_effective_array = Array.new
    goals = self.count_team_goals(self.team_home_id) + self.count_team_goals(self.team_away_id)

    if goals > 0
      effective = self.get_top_effective_hash(gameID).max_by{|k,v| v}[1]
      top_effective_array.push(effective)
      playerID = self.get_top_effective_hash(gameID).max_by{|k,v| v}[0]
      player = self.players.where("player_id = ?", playerID).first
      top_effective_array.push(player.player_surename)
      return top_effective_array
    end
  end

  #
  #
  # Relative Statistiken
  #
  #

  # Ergebnis Mannschaft in Führung
  def get_team_lead(gameID)

    team_lead_array = Array.new

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

    if time_lead_home > time_lead_away
      team_lead_array.push(TickerActivity.convert_seconds_to_time(time_lead_home))
      team_lead_array.push(self.get_club_name_short_by_team_id(self.team_home_id))
    else
      team_lead_array.push(TickerActivity.convert_seconds_to_time(time_lead_away))
      team_lead_array.push(self.get_club_name_short_by_team_id(self.team_away_id))
    end

    return team_lead_array

  end

  # Ergebnis fairste Mannschaft
  def get_team_penalty(gameID)

    team_penalty_array = Array.new

    yellow_home = 0
    yellow_away = 0
    two_home = 0
    two_away = 0
    red_home = 0
    red_away = 0
    fair_home = 0
    fair_away = 0

    self.ticker_activities.each do |ticker_activity|

      if ticker_activity.activity_id == 10400
        if ticker_activity.home_or_away == 1
          yellow_home = yellow_home + 1
        end
        if ticker_activity.home_or_away == 0
          yellow_away = yellow_away + 1
        end
      end

      if ticker_activity.activity_id == 10401
        if ticker_activity.home_or_away == 1
          two_home = two_home + 1
        end
        if ticker_activity.home_or_away == 0
          two_away = two_away + 1
        end
      end

      if ticker_activity.activity_id == 10402
        if ticker_activity.home_or_away == 1
          two_home = two_home + 2
        end
        if ticker_activity.home_or_away == 0
          two_away = two_away + 2
        end
      end

      if ticker_activity.activity_id == 10403
        if ticker_activity.home_or_away == 1
          red_home = red_home + 1
        end
        if ticker_activity.home_or_away == 0
          red_away = red_away + 1
        end
      end

    end

    fair_home = yellow_home + (two_home * 2) + (red_home * 5)
    fair_away = yellow_away + (two_away * 2) + (red_away * 5)

    if fair_home < fair_away
      team_penalty_array.push(yellow_home)
      team_penalty_array.push(two_home)
      team_penalty_array.push(red_home)
      team_penalty_array.push(self.get_club_name_short_by_team_id(self.team_home_id))
    else
      team_penalty_array.push(yellow_away)
      team_penalty_array.push(two_away)
      team_penalty_array.push(red_away)
      team_penalty_array.push(self.get_club_name_short_by_team_id(self.team_away_id))
    end

    return team_penalty_array

  end

  #
  #
  # Funktionen
  #
  #

  def convert_game_date(date)

    if date
      date = DateTime.parse(date)
      result = date.strftime('%d.%m.%Y')
# ToDo => Falls die Uhrzeit in der App eingegeben werden kann, auch hier anzeigen
      #result = date.strftime('%d.%m.%Y, %H:%M:%S')
    end

    return result

  end

end
