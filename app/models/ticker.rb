class Ticker < ActiveRecord::Base

	belongs_to :games
	has_many :join_ticker_players, :dependent => :destroy
	has_many :players, :through => :join_ticker_players
	
end
