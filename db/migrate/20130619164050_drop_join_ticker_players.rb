class DropJoinTickerPlayers < ActiveRecord::Migration
  def up
  	drop_table :join_ticker_players
  end

  def down
  end
end
