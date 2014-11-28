class HomeController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :side, :main, :statistic_home]
  before_filter :check_if_friend, :except => [:index, :side, :main, :statistic_home]

  def index
  	@games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  def search
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  def side
    if params[:query].present?
      logger.debug "Suchfunktion aufgerufen"
      @games = Game.search(params[:query], page: params[:page])
    else
      logger.debug "Alle anzeigen"
      @games = Game.all.page params[:page]
    end

  	respond_to do |format|
      format.html 
      format.js
      format.json { render json: @games }
    end
  end

  def main
    @game = Game.find(params[:game_id])
    @tickers = @game.tickers

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

  def statistic
    @game = Game.find(params[:game_id])
    @tickers = @game.tickers
    @user = User.find(@game.user_id)

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

  def statistic_home
    @game = Game.find(params[:game_id])
    @tickers = @game.tickers

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

  protected

  def check_if_friend
    @game = Game.find(params[:game_id])
    @user = User.find(@game.user_id)
    redirect_to fb_ask_friend_path(:id => @game.user_id), :remote => true, notice: 'Du bist kein Freund' unless current_user.friend.include?(@user) || current_user == @user
  end

  def authenticate_user!
    redirect_to fb_login_path, :remote => true unless current_user
  end
end