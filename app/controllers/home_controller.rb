class HomeController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :side, :main, :statistic_home, :game_main, :imprint]
  before_filter :check_if_friend, :except => [:index, :side, :main, :statistic_home, :game_main, :imprint]

  def index
    setup_last_games_in_cart
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
    @line_items = @cart.line_items.limit(10).all
    logger.debug "+++++++++++++++++++++++ Home / Side nachdem line items created werden +++++++++++++++++++++++"

  	respond_to do |format|
      format.js
    end
  end

  def main
logger.debug "home_controller > main aufgerufen"
    if params[:game_id].present?
      @game = Game.includes(:ticker_activities).find(params[:game_id])
      @ticker_activities = @game.ticker_activities
      @game_overview = @game.get_game_main_stat()
logger.debug "home_controller > main > params game aufgerufen"
    end

    if params[:team_id].present?
      @team = Team.find(params[:team_id])
      @players = @team.players
      @team_games = @team.get_team_games
    end

    if params[:player_id].present?
      @player = Player.find(params[:player_id])
      @player_team = @player.team
      @player_games = @player.get_player_games
    end

    if params[:club_id].present?
      @club = Club.find(params[:club_id])
      @teams = @club.teams
    end

    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @games = @user.games
    end

    if params[:mode].present?
      @mode = params[:mode]
    end

    respond_to do |format|
      # format.html
      format.js
      format.json { render json: @game }
    end
  end

# ToDo => Der allerste Versuch des Aufrufs des Statistik-Hauptfensters funktioniert nicht

  def game_main

    if params[:game_id].present?
      @game = Game.find(params[:game_id])
      @ticker_activities = @game.ticker_activities
      @player_home = @game.get_player_home()
      @player_away = @game.get_player_away()
      @game_stat = @game.get_game_stat()
      @game_possession = @game.get_game_possession()
      @game_lead = @game.get_game_lead()
      @game_history = @game.get_game_history(300, "Statistic")
      @game_penalty = @game.get_game_penalty()
      @ticker_events = @game.ticker_events
    end

    if params[:mode].present?
      @mode = params[:mode]
    end

    respond_to do |format|
      #format.html
      format.js
      format.json { render json: @game }
    end
  end

  def game_statistic_main

    if params[:game_id].present?
      # ToDo => Werden bei einem einzelnen Abruf immer alle Statistiken errechnet?
      @game = Game.find(params[:game_id])
      @game_stat = @game.get_game_stat()
      @game_possession = @game.get_game_possession()
      @game_lead = @game.get_game_lead()
      @game_history = @game.get_game_history(300, "Statistic")
      @game_penalty = @game.get_game_penalty()
      @ticker_events = @game.ticker_events
    end

    if params[:mode].present?
      @mode = params[:mode]
    end

    respond_to do |format|
      #format.html
      format.js
    end
  end

  def game_player_main

    @game = Game.find(params[:game_id])
    @player = Player.find(params[:player_id])
    @player_stat = @game.get_player_stat(params[:player_id], params[:home_or_away])

  end

  def statistic
    @game = Game.find(params[:game_id])
    @ticker_activities = @game.ticker_activities
    @user = User.find(@game.user_id)

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

  def statistic_home
    @game = Game.find(params[:game_id])
    @ticker_activities = @game.ticker_activities

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @game }
    end
  end

  def imprint
    setup_last_games_in_cart
    render layout: 'content'
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
