class HomeController < ApplicationController
  def index
  	@games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  def side
  	respond_to do |format|
      format.html { redirect_to(home_url) }

      format.json { render json: @games }
    end
  end

  def statistic
    @game = Game.find(params[:game_id])
    @tickers = @game.tickers

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

end
