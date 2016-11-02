class PlayersController < ApplicationController

  before_filter :check_if_admin, :only => [:index, :edit]

  def check_if_admin
    begin
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin' unless current_user.name == 'JaqenHghar'
    rescue
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin'
    end
  end
  
  # GET /players
  # GET /players.json
  def index
    @players = Player.search(params[:team_id], params[:player_forename], params[:player_surename])

    respond_to do |format|
      format.html # index.html.erb
      hash = {:players => @players}
      format.json { render :json => hash }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/new
  # GET /players/new.json
  def new
    @player = Player.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/1/edit
  def edit
    @player = Player.find(params[:id])
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(params[:player])

    respond_to do |format|
      if @player.save
# ToDo 0 => Wenn Spieler erstellt wurde, schließe das Fenster und aktualisiere die Spielerliste bzw. die Spielerübersicht
        format.html { redirect_to home_path, notice: 'Player was successfully created.' }
        format.json { render json: @player, status: :created, location: @player }
      else
        format.html { render action: "new" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /players/1
  # PUT /players/1.json
  def update
    @player = Player.find(params[:id])

    respond_to do |format|
      if @player.update_attributes(params[:player])
# ToDo 0 => Wenn Spieler aktualisiert wurde, schließe das Fenster und aktualisiere die Spielerliste bzw. die Spielerübersicht
        format.html { redirect_to home_path, notice: 'Player was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player = Player.find(params[:id])
    @player.destroy

    respond_to do |format|
      format.html { redirect_to players_url }
      format.json { head :no_content }
    end
  end

  def import
    begin
      Player.import(params[:file], params[:team_id])
      redirect_to home_path, notice: "Player imported."
    rescue
      redirect_to home_path, notice: "Invalid CSV file format."
    end
  end

end
