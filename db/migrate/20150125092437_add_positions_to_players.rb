class AddPositionsToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :player_position_first, :string
    add_column :players, :player_position_second, :string
    add_column :players, :player_position_third, :string
  end
end
