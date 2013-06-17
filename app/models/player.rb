class Player < ActiveRecord::Base

	belongs_to :teams
	has_many :tickers, :dependent => :destroy
	has_many :games, :through => :tickers
	
end
