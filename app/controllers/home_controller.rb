class HomeController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :side, :main, :game, :imprint, :help, :help_info, :player_csv]
  before_filter :check_if_friend, :except => [:index, :side, :main, :statistic_home, :game_main, :game_statistic_main, :imprint, :help, :help_info, :player_csv]

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
    if params[:game_id].present?
      @game = Game.includes(:ticker_activities).find(params[:game_id])
      @ticker_activities = @game.ticker_activities
      @game_overview = @game.get_game_main_stat()
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
      @player_home = @game.get_player_home()
      @player_away = @game.get_player_away()
      @scorer_all = @game.get_top_scorer_hash("all")
      @scorer_home = @game.get_top_scorer_hash("home")
      @scorer_away = @game.get_top_scorer_hash("away")

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
    if params[:position_control].present?
      @position_control = params[:position_control]
    else
      @position_control = nil
    end
    if params[:x_click].present?
      @x_click = params[:x_click]
    else
      @x_click = nil
    end
    if params[:y_click].present?
      @y_click = params[:y_click]
    else
      @y_click = nil
    end
    @player_field_matrix = @game.get_player_field_matrix(params[:player_id], @position_control, @x_click, @y_click)
    @player_mode = params[:player_mode]
    @home_or_away = params[:home_or_away]

  end

  def player_statistic_detail

    @game = Game.find(params[:game_id])
    @player = Player.find(params[:player_id])
    @player_stat = @game.get_player_stat(params[:player_id], params[:home_or_away])
    if params[:position_control].present?
      @position_control = params[:position_control]
    else
      @position_control = nil
    end
    if params[:x_click].present?
      @x_click = params[:x_click]
    else
      @x_click = nil
    end
    if params[:y_click].present?
      @y_click = params[:y_click]
    else
      @y_click = nil
    end
# ToDo => player_field_matrix nur dann berechnen, wenn es nicht schon berechnet wurde.
    @player_field_matrix = @game.get_player_field_matrix(params[:player_id], @position_control, @x_click, @y_click)
    @player_mode = params[:player_mode]

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

  def help
    setup_last_games_in_cart
    render layout: 'content'

    if params[:mode].present?
      @mode = params[:mode]
    end
  end

  def help_info
    if params[:mode].present?
      @mode = params[:mode]
    end
  end

  def player_csv
    send_file "#{Rails.root}/public/player.csv", type: "text/csv", x_sendfile: true
  end

  protected

  def check_if_friend
    @game = Game.find(params[:game_id])
    @user = User.find(@game.user_id)
    redirect_to fb_ask_friend_path(:id => @game.user_id), :remote => true, notice: 'Du bist kein Freund' unless current_user.friend.include?(@user) || current_user == @user || current_user.name == 'JaqenHghar'
  end

  def authenticate_user!
    redirect_to fb_login_path, :remote => true unless current_user
  end
end
