class ChangeRemoveTeamName < ActiveRecord::Migration
  def up
  	remove_column :teams, :team_name
  end

  def down
  end
end
