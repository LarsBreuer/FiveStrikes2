class ChangeGameDateFormatInGames < ActiveRecord::Migration
  def change
    change_column :games, :game_date, :string
  end
end
