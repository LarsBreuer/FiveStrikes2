class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :game_id
      t.integer :cart_id
      t.integer :team_id
      t.integer :player_id

      t.timestamps
    end
  end
end
