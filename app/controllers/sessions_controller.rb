class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

def new
  super
end

def create
  self.resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failed_login.js.erb")
  sign_in(resource_name, resource)
  if !session[:return_to].blank?
    redirect_to session[:return_to]
    session[:return_to] = nil
  else
    respond_with resource, :location => after_sign_in_path_for(resource)
  end
end

  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    yield resource if block_given?

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

  def failed_login
      
  end
end