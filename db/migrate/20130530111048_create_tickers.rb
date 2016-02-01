class CreateTickers < ActiveRecord::Migration
  def change
    create_table :tickers do |t|
      t.integer :activity_id
      t.integer :player_id
      t.integer :time

      t.timestamps
    end
  end
end
