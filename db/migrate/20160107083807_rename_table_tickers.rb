class RenameTableTickers < ActiveRecord::Migration
  def up
  	rename_table :tickers, :ticker_activties
  end

  def down
  end
end
