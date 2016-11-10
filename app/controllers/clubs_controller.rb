class ClubsController < ApplicationController



  def check_if_admin
    begin
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin' unless current_user.name == 'JaqenHghar'
    rescue
      redirect_to home_path, :remote => true, notice: 'Du bist kein Admin'
    end
  end

  # GET /clubs
  # GET /clubs.json
  def index
    @clubs = Club.search(params[:club_name], params[:club_id])

    respond_to do |format|
      format.html # index.html.erb
      hash = {:clubs => @clubs}
      format.json { render :json => hash }
    end
  end

  # GET /clubs/1
  # GET /clubs/1.json
  def show
    @club = Club.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @club }
    end
  end

  # GET /clubs/new
  # GET /clubs/new.json
  def new
    @club = Club.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @club }
    end
  end

  # GET /clubs/1/edit
  def edit
    @club = Club.find(params[:id])
  end

  # POST /clubs
  # POST /clubs.json
  def create
    @club = Club.new(params[:club])

    respond_to do |format|
      if @club.save
        format.html { redirect_to @club, notice: 'club was successfully created.' }
        format.json { render json: @club, status: :created, location: @club }
      else
        format.html { render action: "new" }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clubs/1
  # PUT /clubs/1.json
  def update
    @club = Club.find(params[:id])

    respond_to do |format|
      if @club.update_attributes(params[:club])
        format.html { redirect_to @club, notice: 'club was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1
  # DELETE /clubs/1.json
  def destroy
    @club = Club.find(params[:id])
    @club.destroy

    respond_to do |format|
      format.html { redirect_to clubs_url }
      format.json { head :no_content }
    end
  end

  def import
    begin
      Club.import(params[:file])
      redirect_to home_path, notice: "Clubs imported."
    rescue
      redirect_to home_path, notice: "Invalid CSV file format."
    end
  end

end
