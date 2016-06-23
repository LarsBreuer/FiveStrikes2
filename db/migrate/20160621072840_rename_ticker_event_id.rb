class RenameTickerEventId < ActiveRecord::Migration
  def up
  	rename_column :ticker_activities, :ticker_event_id, :ticker_event_id_local
  end

  def down
  end
end
