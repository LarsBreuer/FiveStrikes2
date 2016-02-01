class LineItemsController < InheritedResources::Base

	def create_line_items

		@cart = current_cart

		if params[:query].present?
      logger.debug "+++++++++++++++++++++++ Suchfunktion aufgerufen +++++++++++++++++++++++"
      @games = Game.search(params[:query], page: params[:page])
    else
      logger.debug "Alle anzeigen"
      @games = Game.all.page params[:page]
    end

    @games.each do |game|
    	logger.debug "+++++++++++++++++++++++ Line item hinzugefügt +++++++++++++++++++++++"
    	@line_item = @cart.line_items.build(:game => game)
    	if @line_item.save
				logger.debug "+++++++++++++++++++++++ Line item gespeichert +++++++++++++++++++++++"
      else
				logger.debug "+++++++++++++++++++++++ Line item nicht gespeichert +++++++++++++++++++++++"
			end
    	logger.debug game.club_home_name
      logger.debug game.club_away_name
    end

		redirect_to home_side_path 
		
	end

  def create_team_line_items

    @cart = current_cart
    logger.debug "+++++++++++++++++++++++ Create Team aufgerufen +++++++++++++++++++++++"
    @team = Team.find(params[:team_id])
    logger.debug "+++++++++++++++++++++++ Team als Line item hinzugefügt +++++++++++++++++++++++"
    @line_item = @cart.line_items.build(:team => @team)
    if @line_item.save
      logger.debug "+++++++++++++++++++++++ Team als Line item gespeichert +++++++++++++++++++++++"
    else
      logger.debug "+++++++++++++++++++++++ Team als Line item nicht gespeichert +++++++++++++++++++++++"
    end

    redirect_to home_side_path

  end

end
