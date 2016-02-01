class RenameTickerActivitys < ActiveRecord::Migration
  def up
  	rename_table :ticker_activitys, :ticker_activities
  end

  def down
  end
end
