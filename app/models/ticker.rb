class Ticker < ActiveRecord::Base

	belongs_to :game
	belongs_to :player
	belongs_to :team
	
	def convert_seconds_to_time(seconds)
		total_minutes = seconds / 1.minutes
		seconds_in_last_minute = seconds - total_minutes.minutes.seconds
		"#{sprintf '%02d', total_minutes}:#{sprintf '%02d', seconds_in_last_minute}"
	end
end
