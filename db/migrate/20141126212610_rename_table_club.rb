class RenameTableClub < ActiveRecord::Migration
  def up
  	rename_table :club, :clubs
  end

  def down
  end	
end
