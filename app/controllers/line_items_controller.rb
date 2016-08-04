class LineItemsController < InheritedResources::Base

	def create_line_items

		@cart = current_cart
    choice = params[:choice_id]

    if choice == '1'
		  if params[:query].present?
        @games = Game.search_items(params[:query])
      else
        logger.debug "Alle anzeigen"
        @games = Game.all.page params[:page]
      end

      @games.each do |game|
        @line_item = @cart.line_items.build(:game => game)
        if @line_item.save
        else
        end
        logger.debug game.club_home_name
        logger.debug game.club_away_name
      end
    end

    if choice == '2'
      if params[:query].present?
        @teams = Team.search(params[:query], nil, nil)
      else
        logger.debug "Alle anzeigen"
        @teams = Team.all.page params[:page]
      end

      @teams.each do |team|
        @line_item = @cart.line_items.build(:team => team)
        if @line_item.save
        else
        end
      end
    end

# ToDo => Nach Spielern suchen einfügen

    if choice == '4'
      if params[:query].present?
        @clubs = Club.search(params[:query], nil)
      else
        @clubs = Club.all.page params[:page]
      end

      @clubs.each do |club|
        @line_item = @cart.line_items.build(:club => club)
        if @line_item.save
        else
        end
      end
    end

    if choice == '5'
      if params[:query].present?
        @users = User.search(params[:query])
      end

      @users.each do |user|
        @line_item = @cart.line_items.build(:user => user)
        if @line_item.save
        else
        end
      end
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
# ToDo => Beim Aufruf eines Teams das Team auch im Hauptfenster anzeigen
    redirect_to home_side_path

  end

  def create_player_line_items

    @cart = current_cart
    @player = Player.find(params[:player_id])
    @line_item = @cart.line_items.build(:player => @player)
    if @line_item.save
      
    else
      
    end
# ToDo => Beim Aufruf eines Spielers den Spieler auch im Hauptfenster anzeigen
    redirect_to home_side_path

  end

  def create_game_line_items

    @cart = current_cart
    @game = Game.find(params[:game_id])
    @line_item = @cart.line_items.build(:game => @game)
    if @line_item.save
      
    else
      
    end
# ToDo => Beim Aufruf eines Teams das Team auch im Hauptfenster anzeigen
    redirect_to home_side_path

  end

end
