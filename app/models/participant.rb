class Participant < ActiveRecord::Base

	searchkick
	
	belongs_to :game
	belongs_to :team

end
