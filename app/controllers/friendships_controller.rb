class FriendshipsController < InheritedResources::Base

  def req
    @user = current_user
    @friend = User.find(params[:id])
    unless @friend.nil?
      if Friendship.request(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.name} requested"
      else
        flash[:notice] = "Friendship with #{@friend.name} cannot be requested"
      end
    end
    redirect_to home_path
  end

  def accept
    @user = current_user
    @friend = User.find(params[:id])
    unless @friend.nil?
      if Friendship.accept(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.name} accepted"
      else
        flash[:notice] = "Friendship with #{@friend.name} cannot be accepted"
      end
    end
    redirect_to home_path
  end

  def reject
    @user = current_user
    @friend = User.find(params[:id])
    unless @friend.nil?
      if Friendship.reject(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.name} rejected"
      else
        flash[:notice] = "Friendship with #{@friend.name} cannot be rejected"
      end
    end
    redirect_to home_path
  end
end
