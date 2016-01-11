class TickersController < ApplicationController
  # GET /ticker_activities
  # GET /ticker_activities.json
  def index
    @ticker_activities = Ticker_activity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ticker_activities }
    end
  end

  # GET /ticker_activities/1
  # GET /ticker_activities/1.json
  def show
    @ticker_activity = Ticker_activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ticker_activity }
    end
  end

  # GET /ticker_activities/new
  # GET /ticker_activities/new.json
  def new
    @ticker_activity = Ticker_activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticker_activity }
    end
  end

  # GET /ticker_activities/1/edit
  def edit
    @ticker_activity = Ticker_activity.find(params[:id])
  end

  # POST /ticker_activities
  # POST /ticker_activities.json
  def create
    @ticker_activity = Ticker_activity.new(params[:ticker_activity])

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

  # PUT /ticker_activities/1
  # PUT /ticker_activities/1.json
  def update
    @ticker_activity = Ticker_activity.find(params[:id])

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
    @ticker_activity = Ticker_activity.find(params[:id])
    @ticker_activity.destroy

    respond_to do |format|
      format.html { redirect_to tickers_url }
      format.json { head :no_content }
    end
  end
end
