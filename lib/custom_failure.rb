class CustomFailure < Devise::FailureApp

  def redirect_url
    #flash[:notice] = fading_flash_message("Login fehlgeschlagen", 5)
    home_path
    #failed_login_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

end