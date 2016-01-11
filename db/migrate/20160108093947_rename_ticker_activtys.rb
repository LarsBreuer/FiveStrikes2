class RenameTickerActivtys < ActiveRecord::Migration
  def up
  	rename_table :ticker_activtys, :ticker_activitys
  end

  def down
  end
end
