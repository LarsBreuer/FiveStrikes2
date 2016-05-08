class FaceboxController < ApplicationController


# facebox stub functions
# real work is done in JS.ERB files under views/facebox
# or if not JS, then views under views/devise



  def fb_edit_user
  end

  def fb_create_user
  end

  def fb_login
  end

  def fb_reset_password
  end

  def fb_ask_friend
    @user = User.find(params[:id])
    @user.id = params[:id]

    respond_to do | format |
      format.js {render :layout => false}
    end
  end

  def fb_find_friends
    @users = User.all

    respond_to do | format |
      format.js {render :layout => false}
    end
  end

  def fb_player_edit
    @player = Player.find(params[:player_id])
    respond_to do |format|
      format.js
    end
  end

  def fb_player_new
    @player = Player.new
    respond_to do |format|
      format.js
    end
  end

  def fb_team_new
    @team = Team.new
    @club = Club.find(params[:club_id])
    @team_club_name = @club.club_name
    respond_to do |format|
      format.js
    end
  end

end