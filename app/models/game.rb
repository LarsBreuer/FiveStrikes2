class Game < ActiveRecord::Base

	has_many :participants, :dependent => :destroy
	has_many :teams, :through => :participants
  has_many :tickers, :dependent => :destroy
  has_many :players, :through => :tickers
  belongs_to :user

	accepts_nested_attributes_for :participants,
    :reject_if => lambda {|a| a[:game_id].blank? },
       :allow_destroy => :true

  def home_team
    self.teams.joins(:participants).where("participants.home_team = ?", true).first
  end
  	
  def away_team
    self.teams.joins(:participants).where("participants.home_team = ?", false).first
  end

  def count_team_activity(activityID, teamID)
    self.tickers.where(:activity_id => activityID, :team_id => teamID).count
  end

  def count_team_goals_time(teamID, time)
    self.tickers.where("activity_id = ? AND team_id = ? AND time <= ?", 1, teamID, time).count
  end

end
