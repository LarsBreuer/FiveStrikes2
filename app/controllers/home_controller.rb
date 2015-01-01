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
    logger.debug "+++++++++++++++++++++++ Home / Side wird aufgerufen +++++++++++++++++++++++"
    @cart = current_cart
    logger.debug "+++++++++++++++++++++++ Home / Side bevor line items created werden +++++++++++++++++++++++"
    @line_items = @cart.line_items.all(:order => 'updated_at DESC', :limit => 10)
    logger.debug "+++++++++++++++++++++++ Home / Side nachdem line items created werden +++++++++++++++++++++++"

  	respond_to do |format|
      format.js
    end
  end

  def main
    
    if params[:game_id].present?
      @game = Game.find(params[:game_id])
      @tickers = @game.tickers
    end

    if params[:team_id].present?
      @team = Team.find(params[:team_id])
    end

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