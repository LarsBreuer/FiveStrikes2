class ChangeTeamNameToId < ActiveRecord::Migration
  def up
  	add_column :teams, :team_type_id, :integer
  end

  def down
  	
  end
end
