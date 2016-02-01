class AddClubNameToGames < ActiveRecord::Migration
  def up
	add_column :games, :club_home_name, :string
	add_column :games, :club_away_name, :string
  end

  def down
  end
end
