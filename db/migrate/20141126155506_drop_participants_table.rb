class DropParticipantsTable < ActiveRecord::Migration
  def up
  	drop_table :participants
  end

  def down
  	
  end
end
