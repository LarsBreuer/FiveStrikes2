class AddTickerItemsToTickerActivities < ActiveRecord::Migration
  def change
  	add_column :ticker_activities, :realtime, :string
  	add_column :ticker_activities, :home_or_away, :integer
  	add_column :ticker_activities, :goal_area, :string
  	add_column :ticker_activities, :field_position_x, :integer
  	add_column :ticker_activities, :field_position_y, :integer
  	add_column :ticker_activities, :throwing_technique_id, :integer
  	add_column :ticker_activities, :ticker_activity_note, :text
  	add_column :ticker_activities, :mark, :integer
  end
end
