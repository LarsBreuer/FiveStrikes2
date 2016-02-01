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

end