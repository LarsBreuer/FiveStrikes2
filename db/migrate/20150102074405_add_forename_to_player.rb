class AddForenameToPlayer < ActiveRecord::Migration
	
  def self.up
  	add_column :players, :player_forename, :string
  	add_column :players, :player_surename, :string
  	remove_column :players, :player_name
  end

end
