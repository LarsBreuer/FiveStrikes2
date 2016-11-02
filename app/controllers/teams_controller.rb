class TeamsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index]
  before_filter :check_if_admin, :only => [:index, :edit]

  def check_if_admin
    begin
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin' unless current_user.name == 'JaqenHghar'
    rescue
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin'
    end
  end

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
    valid = false
    team_exists = false
    if params[:gender_id] != "0" and params[:age_id] != "0" and params[:class_id] != "0"
      # ToDo => Die ersten beiden Zahlen für die Sportart dynamisch generieren
      team_type_id = "10#{params[:gender_id]}#{params[:age_id]}#{params[:class_id]}"
      if club = (Club.find(params[:team][:club_id]))
        unless (@team = club.teams.where(team_club_name: params[:team][:team_club_name], team_type_id: team_type_id).first)
          @team = Team.create(params[:team].merge(team_type_id: team_type_id))
          valid = true
        else
          team_exists = true
        end
      end
    end
    respond_to do |format|
      if valid and @team and @team.save
        format.html { redirect_to home_path, notice: 'Team was successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
        format.js   { render :action => "create" }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
        format.js do
          if team_exists
            render js: js_error_message('Diese Mannschaft existiert bereits!')
          else
            render js: js_error_message('Bitte ergänzen Sie alle Felder!')
          end
        end
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
