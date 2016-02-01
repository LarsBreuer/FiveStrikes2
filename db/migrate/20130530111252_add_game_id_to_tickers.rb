class AddGameIdToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :game_id, :integer

  end
end
