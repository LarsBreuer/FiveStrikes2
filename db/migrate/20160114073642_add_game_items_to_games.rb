class AddGameItemsToGames < ActiveRecord::Migration
  def change
  	add_column :games, :duration_halftime, :integer
  	add_column :games, :game_date, :date
  	add_column :games, :game_note, :text
  end
end
