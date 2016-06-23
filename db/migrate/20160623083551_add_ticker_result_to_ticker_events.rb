class AddTickerResultToTickerEvents < ActiveRecord::Migration
  def change
    add_column :ticker_events, :ticker_result, :string
  end
end
