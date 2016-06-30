class TickerActivity < ActiveRecord::Base

	belongs_to :game
	belongs_to :player
	belongs_to :team
	
	def self.convert_seconds_to_time(seconds)
		seconds = seconds / 1000
		total_minutes = seconds / 1.minutes
		seconds_in_last_minute = seconds - total_minutes.minutes.seconds
		"#{sprintf '%02d', total_minutes}:#{sprintf '%02d', seconds_in_last_minute}"
	end

	# Import CSV-File
	def self.import(file)
    	CSV.foreach(file.path, headers: true) do |row|

      		ticker_hash = row.to_hash 
        	TickerActivity.create!(ticker_hash)

    	end
  	end
end
