class Ticker < ActiveRecord::Base

	belongs_to :games
	belongs_to :players
	
end
