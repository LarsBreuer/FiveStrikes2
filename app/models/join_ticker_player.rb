class JoinTickerPlayer < ActiveRecord::Base

	belongs_to :ticker
	belongs_to :player

end
