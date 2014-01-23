class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_msg, :set_msg, :clear_msg, :is_msg?
  include ActionView::Helpers::OutputSafetyHelper
  
  def after_sign_in_path_for(resource)
    home_path
  end

  private
  
  def after_sign_out_path_for(resource_or_scope)
    home_path
  end
 
  def check_access_level(role)
     redirect_to home_path unless current_user.role_access?(role)
  end
  
  def after_omniauth_failure_path_for(resource)
    home_path
  end
  
  def after_inactive_sign_up_path_for(resource)
    home_path
  end

  # for passing around flash messages to/from js.erb
  #def current_msg
    #return session[:msg] if defined?(session[:msg])
    #return ''
  #end
  #def set_msg str
    #session[:msg] = str
  #end
  #def clear_msg
    #session[:msg] = ''
  #end
  #def is_msg?
    #return true if session[:msg] && session[:msg].length > 0
  #end

end
