class TickerActivity < ActiveRecord::Base

	belongs_to :game
	belongs_to :player
	belongs_to :team
	
	def self.convert_seconds_to_time(seconds)
		seconds = seconds
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

  	def self.convert_activity_id_to_activity(activity_id)
  		activity = ""

  		activity = I18n.t('basic.possession') if activity_id == 10099

  		activity = I18n.t('basic.shot_on_goal') if activity_id == 10100
  		activity = I18n.t('basic.seven_goal') if activity_id == 10101
  		activity = I18n.t('basic.fb_goal') if activity_id == 10102

  		activity = I18n.t('basic.miss') if activity_id == 10150
  		activity = I18n.t('basic.seven_miss') if activity_id == 10151
  		activity = I18n.t('basic.fb_miss') if activity_id == 10152

  		activity = I18n.t('basic.gk_save') if activity_id == 10200
  		activity = I18n.t('basic.seven_save') if activity_id == 10201
  		activity = I18n.t('basic.fb_save') if activity_id == 10202
  		
  		activity = I18n.t('basic.goal_against') if activity_id == 10250
  		activity = I18n.t('basic.seven_goal_against') if activity_id == 10251
  		activity = I18n.t('basic.fb_goal_against') if activity_id == 10252

		  activity = I18n.t('basic.assist_goal') if activity_id == 10160
  		activity = I18n.t('basic.assist_missed') if activity_id == 10161

  		activity = I18n.t('basic.defense_error') if activity_id == 10170
  		activity = I18n.t('basic.defense_success') if activity_id == 10171
  		activity = I18n.t('basic.block_error') if activity_id == 10172
  		activity = I18n.t('basic.block_success') if activity_id == 10173
  		activity = I18n.t('basic.foul') if activity_id == 10174

  		activity = I18n.t('basic.tech_fault') if activity_id == 10300
  		activity = I18n.t('basic.Fehlpass') if activity_id == 10301
  		activity = I18n.t('basic.steps') if activity_id == 10302
  		activity = I18n.t('basic.three_seconds') if activity_id == 10303
  		activity = I18n.t('basic.Doppeldribbel') if activity_id == 10304
  		activity = I18n.t('basic.Fuss') if activity_id == 10305
  		activity = I18n.t('basic.Zeitspiel') if activity_id == 10306
  		activity = I18n.t('basic.Kreis') if activity_id == 10307
  		activity = I18n.t('basic.Stuermerfoul') if activity_id == 10308

  		activity = I18n.t('basic.yellow_card') if activity_id == 10400
  		activity = I18n.t('basic.two_minutes') if activity_id == 10401
  		activity = I18n.t('basic.two_plus_two') if activity_id == 10402
  		activity = I18n.t('basic.red_card') if activity_id == 10403

  		activity = I18n.t('basic.lineup') if activity_id == 10500
  		activity = I18n.t('basic.sub_in') if activity_id == 10501
  		activity = I18n.t('basic.sub_out') if activity_id == 10502
  		activity = I18n.t('basic.suspension_end') if activity_id == 10503

  		activity = I18n.t('basic.timeout') if activity_id == 10600

  		activity = I18n.t('basic.tactic_60') if activity_id == 10700
  		activity = I18n.t('basic.tactic_51') if activity_id == 10701
  		activity = I18n.t('basic.tactic_42') if activity_id == 10702
  		activity = I18n.t('basic.guarding') if activity_id == 10703
  		activity = I18n.t('basic.tactic_321') if activity_id == 10704

  		activity = I18n.t('basic.Sprungwurf') if activity_id == 10180
  		activity = I18n.t('basic.Schlagwurf') if activity_id == 10181
  		activity = I18n.t('basic.Laufwurf') if activity_id == 10182
  		activity = I18n.t('basic.Fallwurf') if activity_id == 10183
  		activity = I18n.t('basic.Hueftwurf') if activity_id == 10184
  		activity = I18n.t('basic.kempa') if activity_id == 10185
  		activity = I18n.t('basic.Dreher') if activity_id == 10186
  		activity = I18n.t('basic.Heber') if activity_id == 10187
  		activity = I18n.t('basic.Leger') if activity_id == 10188
  		activity = I18n.t('basic.Abknickwurf') if activity_id == 10189

  		return activity
  	end
end
