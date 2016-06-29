class FrameController < ApplicationController

  def game

  	@game =  Game.find(params[:game])
  	@ticker_events = @game.ticker_events

  end

end
