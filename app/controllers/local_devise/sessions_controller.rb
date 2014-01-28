class LocalDevise::SessionsController < Devise::SessionsController


  def create
    self.resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failed_login")
    sign_in(resource_name, resource)
    #set_msg t(:signed_in, :scope => 'devise.sessions')
    respond_to do |format|
      format.js
      # and now keep placeholder integration test happy
      format.html {render :nothing => true, :status => 200, :content_type => 'text/html'}
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
    set_msg t(:invalid, :scope => 'devise.failure')  
  end
  
end