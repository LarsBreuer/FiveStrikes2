class RenameClubName < ActiveRecord::Migration
  def up
  	rename_column :clubs, :name, :club_name
  end

  def down
  end
end
