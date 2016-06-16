class AddTickerEventIdLocalToTickerEvents < ActiveRecord::Migration
  def change
    add_column :ticker_events, :ticker_event_id_local, :integer
  end
end
