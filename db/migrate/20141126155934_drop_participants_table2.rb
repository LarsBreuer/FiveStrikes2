class DropParticipantsTable2 < ActiveRecord::Migration
  def up
  	drop_table :participants
  end

  def down
  	
  end
end
