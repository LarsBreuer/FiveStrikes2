class GamesController < ApplicationController

  before_filter :authenticate_user!, :except => [:show]
  # before_filter :check_if_admin, :only => [:index, :edit]

  def check_if_admin
    begin
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin' unless current_user.name == 'JaqenHghar'
    rescue
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin'
    end
  end

  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    @game_overview = @game.get_game_main_stat()
    @ticker_activities = @game.ticker_activities
    respond_to do |format|
      format.html do
        unless params[:edit]
          cart = current_cart
          cart.line_items.create(game: @game)
          @line_items = cart.line_items.limit(100).all
          render layout: 'content'
        end
      end
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
# ToDo => Bei Löschen eines Spiels erhalte ich die Fehlermeldung "undefined method `name' for nil:NilClass"
# Lösung eventuell Ruby-Version ändern, siehe hier: http://stackoverflow.com/questions/23568084/create-with-has-many-through-association-gets-nomethoderror-undefined-method-n
# Aber dies könnte eventuell andere Probleme bereiten, z.B. mit Heroku (siehe eMail vom 04.02.2016).
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end
end
