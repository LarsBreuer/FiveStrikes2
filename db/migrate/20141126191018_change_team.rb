class ChangeTeam < ActiveRecord::Migration
  def up
  	add_column :teams, :club_id, :integer
  end

  def down
  end
end
