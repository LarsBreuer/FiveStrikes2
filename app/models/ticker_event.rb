class TickerEvent < ActiveRecord::Base

	attr_accessible :game_id, :ticker_event_note, :time, :ticker_event_id_local, :activity_id, :ticker_result, :home_or_away

  	belongs_to :game

  	def convert_seconds_to_time(seconds)
  		seconds = seconds / 1000
		total_minutes = seconds / 1.minutes
		seconds_in_last_minute = seconds - total_minutes.minutes.seconds
		"#{sprintf '%02d', total_minutes}:#{sprintf '%02d', seconds_in_last_minute}"
	end
  
end
