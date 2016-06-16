class TickerEvent < ActiveRecord::Base
  attr_accessible :game_id, :ticker_event_note, :time

  belongs_to :game
  
end
