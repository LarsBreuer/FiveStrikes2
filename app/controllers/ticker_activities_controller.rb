class TickerActivitiesController < ApplicationController
  # GET /ticker_activities
  # GET /ticker_activities.json
  def index
    @ticker_activities = TickerActivity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ticker_activities }
    end
  end

  # GET /ticker_activities/1
  # GET /ticker_activities/1.json
  def show
    @ticker_activity = TickerActivity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ticker_activity }
    end
  end

  # GET /ticker_activities/new
  # GET /ticker_activities/new.json
  def new
    @ticker_activity = TickerActivity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticker_activity }
    end
  end

  # GET /ticker_activities/1/edit
  def edit
    @ticker_activity = TickerActivity.find(params[:id])
  end

  # POST /ticker_activities
  # POST /ticker_activities.json
  def create
    
    params["_json"].each do |params_hash|
      puts params_hash.inspect
      @ticker_activity = TickerActivity.new(params_hash)
      @ticker_activity.save
    end

    #@ticker_activity = TickerActivity.new(params[:ticker_activity])

    respond_to do |format|
      if @ticker_activity.save
        format.html { redirect_to @ticker_activity, notice: 'Ticker was successfully created.' }
        format.json { render json: @ticker_activity, status: :created, location: @ticker_activity }
      else
        format.html { render action: "new" }
        format.json { render json: @ticker_activity.errors, status: :unprocessable_entity }
      end
    end
  end

# POST /multiple_ticker_activities
# POST /multiple_ticker_activities.json
def create_multiple
  puts params

  @ticker_activities = params["_json"].map do |params_hash|
    whitelisted_params = params_hash.permit(:activity_id, :player_id, :time, :game_id)
    TickerActivity.new(whitelisted_params)      
  end

  respond_to do |format|
    # Check that all the ticker_activities are valid and can be saved
    if @ticker_activities.all? { |ticker_activity| ticker_activity.valid? }
      # Now we know they are valid save each ticker_activity
      @ticker_activities.each do |ticker_activity|
        ticker_activity.save
      end

      # Respond with the json versions of the saved ticker_activites
      format.json { render json: @ticker_activities, status: :created, location: multiple_ticker_locations_url }
    }
    else
      # We can't save *all* the ticker_activities so we
      # respond with the corresponding validation errors for the ticker_activities
      @errors = @ticker_activities.map { |ticker_activity|
        ticker_activity.errors
      }
      format.json { render json: @errors, status: :unprocessable_entity }
    end
  end
end

  # PUT /ticker_activities/1
  # PUT /ticker_activities/1.json
  def update
    @ticker_activity = TickerActivity.find(params[:id])

    respond_to do |format|
      if @ticker_activity.update_attributes(params[:ticker_activity])
        format.html { redirect_to @ticker_activity, notice: 'Ticker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ticker_activity.errors, status: :unprocessable_entity }
      end
  end
    end

  # DELETE /ticker_activities/1
  # DELETE /ticker_activities/1.json
  def destroy
    @ticker_activity = TickerActivity.find(params[:id])
    @ticker_activity.destroy

    respond_to do |format|
      format.html { redirect_to ticker_activities_url }
      format.json { head :no_content }
    end
  end

  def import
    begin
      TickerActivity.import(params[:file])
      redirect_to home_path, notice: "Ticker imported."
    rescue
      redirect_to home_path, notice: "Invalid CSV file format."
    end
  end
end
