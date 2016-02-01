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
    
    params["_json"].each do |param_hash|
      ticker = TickerActivity.create!(params_hash)
    end
    
    #@ticker_activity = TickerActivity.new(params[:ticker_activity])

    #respond_to do |format|
    #  if @ticker_activity.save
    #    format.html { redirect_to @ticker_activity, notice: 'Ticker was successfully created.' }
    #    format.json { render json: @ticker_activity, status: :created, location: @ticker_activity }
    #  else
    #    format.html { render action: "new" }
    #    format.json { render json: @ticker_activity.errors, status: :unprocessable_entity }
    #  end
    #end
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
