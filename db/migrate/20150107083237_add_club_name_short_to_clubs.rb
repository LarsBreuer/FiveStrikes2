class AddClubNameShortToClubs < ActiveRecord::Migration
  def self.up
    add_column :clubs, :club_name_short, :string
  end
end
