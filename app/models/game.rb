class Game < ActiveRecord::Base

  searchkick
  
  has_many :ticker_activities, :dependent => :destroy
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  # ToDo => Überprüfung, ob Spiel tatsächlich zerstört werden darf, einrichten
  # before_destroy :ensure_not_referenced_by_any_line_item

  def get_club_name_by_team_id(team_id)
	logger.debug "Team ID: #{team_id}"
	Team.find(:first, :conditions => [ "id = ?", team_id ]).club.club_name
  end 

  def count_team_activity(activityID, teamID)
    self.ticker_activities.where(:activity_id => activityID, :team_id => teamID).count
  end

  def count_team_goals_time(teamID, time)
    self.ticker_activities.where("activity_id = ? AND team_id = ? AND time <= ?", 10100, teamID, time).count
  end

  def count_team_goals(teamID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND team_id = ? AND game_id <= ?", 10100, 10101, 10102, teamID, gameID).count
  end

  def count_player_goals(playerID, gameID)
    self.ticker_activities.where("(activity_id = ? OR activity_id = ? OR activity_id = ?) AND player_id = ? AND game_id <= ?", 10100, 10101, 10102, playerID, gameID).count
  end

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

end
