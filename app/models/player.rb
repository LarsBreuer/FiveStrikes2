class Player < ActiveRecord::Base

	belongs_to :teams
	has_many :join_ticker_players, :dependent => :destroy
	has_many :tickers, :through => :join_ticker_players
	
end
