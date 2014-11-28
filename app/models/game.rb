class Game < ActiveRecord::Base

  searchkick
  
  has_many :tickers, :dependent => :destroy
  has_many :players, :through => :tickers
  belongs_to :user

  def get_club_name_by_team_id(team_id)
	logger.debug "Team ID: #{team_id}"
	Team.find(:first, :conditions => [ "id = ?", team_id ]).club.club_name
  end 

  def count_team_activity(activityID, teamID)
    self.tickers.where(:activity_id => activityID, :team_id => teamID).count
  end

  def count_team_goals_time(teamID, time)
    self.tickers.where("activity_id = ? AND team_id = ? AND time <= ?", 1, teamID, time).count
  end

end
