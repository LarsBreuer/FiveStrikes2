class AddHomeTeamToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :home_team, :boolean

  end
end
