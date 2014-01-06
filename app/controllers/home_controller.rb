class HomeController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :side]

  def index
  	@games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  def side
  	respond_to do |format|
      format.html 
      format.json { render json: @games }
    end
  end

  def statistic
    @game = Game.find(params[:game_id])
    @tickers = @game.tickers

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

end
