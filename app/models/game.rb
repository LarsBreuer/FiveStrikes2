class Game < ActiveRecord::Base

  searchkick
  
  has_many :ticker_activities, :dependent => :destroy
  has_many :players, :through => :ticker_activities
  belongs_to :user
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  def get_club_name_by_team_id(team_id)
	logger.debug "Team ID: #{team_id}"
	Team.find(:first, :conditions => [ "id = ?", team_id ]).club.club_name
  end 

  def count_team_activity(activityID, teamID)
    self.ticker_activities.where(:activity_id => activityID, :team_id => teamID).count
  end

  def count_team_goals_time(teamID, time)
    self.ticker_activities.where("activity_id = ? AND team_id = ? AND time <= ?", 1, teamID, time).count
  end

end
