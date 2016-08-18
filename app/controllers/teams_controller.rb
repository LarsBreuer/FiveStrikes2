class TeamsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index]
  
  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.search(params[:team_name], params[:club_id], params[:team_type])

    respond_to do |format|
      format.html # index.html.erb
      hash = {:teams => @teams}
      format.json { render :json => hash }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @team = Team.find(params[:id])
    @players = @team.players
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.json
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.json
  def create
    team_type_id = "10" + params[:gender_id] + params[:age_id] + params[:class_id]
    @team = Team.create!(params[:team].merge(team_type_id: team_type_id))
# ToDo => Die ersten beiden Zahlen für die Sportart dynamisch generieren 
# ToDo => Überprüfen, ob die Mannschaft schon vorhanden ist und nur dann abspeichern
# ToDo => Überprüfen, ob alle Angaben (gender_id, age_id und class_id) gemacht wurden

    respond_to do |format|
      if @team.save
# ToDo => Nur Facebox schließen und nicht zum Home-Path weiterleiten
        format.html { redirect_to home_path, notice: 'Team was successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.json
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end
end
