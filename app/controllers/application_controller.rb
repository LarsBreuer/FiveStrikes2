class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_msg, :set_msg, :clear_msg, :is_msg?
  
  def after_sign_in_path_for(resource)
    home_path
  end

  # for passing around flash messages to/from js.erb
  def current_msg
    return session[:msg] if defined?(session[:msg])
    return ''
  end
  def set_msg str
    session[:msg] = str
  end
  def clear_msg
    session[:msg] = ''
  end
  def is_msg?
    return true if session[:msg] && session[:msg].length > 0
  end

end
