class AddTickerEventIdToTickerActivities < ActiveRecord::Migration
  def change
    add_column :ticker_activities, :ticker_event_id, :integer
  end
end
