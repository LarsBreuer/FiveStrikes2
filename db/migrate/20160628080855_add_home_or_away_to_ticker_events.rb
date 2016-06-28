class AddHomeOrAwayToTickerEvents < ActiveRecord::Migration
  def change
    add_column :ticker_events, :home_or_away, :integer
  end
end
