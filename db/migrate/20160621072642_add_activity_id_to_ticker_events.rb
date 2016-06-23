class AddActivityIdToTickerEvents < ActiveRecord::Migration
  def change
    add_column :ticker_events, :activity_id, :integer
  end
end
