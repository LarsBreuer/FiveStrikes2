class CreateClubTable < ActiveRecord::Migration
  def up
  	create_table :club do |t|
      t.string  :name
    end
  end

  def down
  end
end
