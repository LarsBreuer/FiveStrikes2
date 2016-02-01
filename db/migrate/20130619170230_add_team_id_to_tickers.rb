class AddTeamIdToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :team_id, :integer

  end
end
