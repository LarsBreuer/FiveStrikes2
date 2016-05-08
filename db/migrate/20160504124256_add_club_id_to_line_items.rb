class AddClubIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :club_id, :integer
  end
end
