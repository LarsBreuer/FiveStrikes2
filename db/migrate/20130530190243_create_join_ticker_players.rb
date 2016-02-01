class CreateJoinTickerPlayers < ActiveRecord::Migration
  def change
    create_table :join_ticker_players do |t|
      t.integer :ticker_id
      t.integer :player_id

      t.timestamps
    end
  end
end
