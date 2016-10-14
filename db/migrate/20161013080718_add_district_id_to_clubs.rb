class AddDistrictIdToClubs < ActiveRecord::Migration
  def change
    add_column :clubs, :district_id, :integer
  end
end
