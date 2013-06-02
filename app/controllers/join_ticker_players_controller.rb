class JoinTickerPlayersController < ApplicationController
  # GET /join_ticker_players
  # GET /join_ticker_players.json
  def index
    @join_ticker_players = JoinTickerPlayer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @join_ticker_players }
    end
  end

  # GET /join_ticker_players/1
  # GET /join_ticker_players/1.json
  def show
    @join_ticker_player = JoinTickerPlayer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @join_ticker_player }
    end
  end

  # GET /join_ticker_players/new
  # GET /join_ticker_players/new.json
  def new
    @join_ticker_player = JoinTickerPlayer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @join_ticker_player }
    end
  end

  # GET /join_ticker_players/1/edit
  def edit
    @join_ticker_player = JoinTickerPlayer.find(params[:id])
  end

  # POST /join_ticker_players
  # POST /join_ticker_players.json
  def create
    @join_ticker_player = JoinTickerPlayer.new(params[:join_ticker_player])

    respond_to do |format|
      if @join_ticker_player.save
        format.html { redirect_to @join_ticker_player, notice: 'Join ticker player was successfully created.' }
        format.json { render json: @join_ticker_player, status: :created, location: @join_ticker_player }
      else
        format.html { render action: "new" }
        format.json { render json: @join_ticker_player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /join_ticker_players/1
  # PUT /join_ticker_players/1.json
  def update
    @join_ticker_player = JoinTickerPlayer.find(params[:id])

    respond_to do |format|
      if @join_ticker_player.update_attributes(params[:join_ticker_player])
        format.html { redirect_to @join_ticker_player, notice: 'Join ticker player was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @join_ticker_player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /join_ticker_players/1
  # DELETE /join_ticker_players/1.json
  def destroy
    @join_ticker_player = JoinTickerPlayer.find(params[:id])
    @join_ticker_player.destroy

    respond_to do |format|
      format.html { redirect_to join_ticker_players_url }
      format.json { head :no_content }
    end
  end
end
