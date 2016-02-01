class AddClubNameToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :team_club_name, :string
  end
end
