class CreateTickerEvents < ActiveRecord::Migration
  def change
    create_table :ticker_events do |t|
      t.integer :game_id
      t.integer :time
      t.text :ticker_event_note

      t.timestamps
    end
  end
end
