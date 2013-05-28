class Game < ActiveRecord::Base

	has_many :participants, :dependent => :destroy
	has_many :teams, :through => :participants

	accepts_nested_attributes_for :participants,
    :reject_if => lambda {|a| a[:game_id].blank? },
       :allow_destroy => :true

  def home_team
    self.teams.joins(:participants).where("participants.home_team = ?", true).first
  end
  	
  def away_team
    self.teams.joins(:participants).where("participants.home_team = ?", false).first
  end

end
