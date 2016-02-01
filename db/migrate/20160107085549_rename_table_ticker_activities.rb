class RenameTableTickerActivities < ActiveRecord::Migration
  def up
  	rename_table :ticker_activties, :ticker_activtys
  end

  def down
  end
end
