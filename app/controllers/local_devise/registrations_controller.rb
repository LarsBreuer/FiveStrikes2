class LocalDevise::RegistrationsController < Devise::RegistrationsController

              
  # NOTE: some functionality has been removed for this project - check parent controller

  def create
    build_resource


    # Für den lokalen Modus Confirmation überspringen
    resource.skip_confirmation!
    



    #resource.role = User.user_role

    if resource.save
      if resource.active_for_authentication?
        sign_in(resource_name, resource)
        log_sign_in
        set_msg t(:signed_up, :scope => 'devise.registrations')
      else
        set_msg t(:"signed_up_but_#{resource.inactive_message}", :scope => 'devise.registrations')
        #expire_data_after_sign_in!
      end
    else
      clean_up_passwords resource
      set_msg t(:signed_up_failure, :scope => 'devise.registrations')
# ToDo => Eigener Fehlertext, falls die Nutzungsbedingungen nicht bestätigt wurden.
      respond_to do |format|
        format.js { render :action => "failed_new" }
      end
    end
  end
  
  # Comment from Devise parent controller: 
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(resource_params)
      sign_in resource_name, resource, :bypass => true
      if resource.email_unconfirmed?
        set_msg t(:updated_email, :scope => 'myinfo.devise.messages')
      else
        set_msg t(:updated, :scope => 'devise.registrations')
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.js { render :action => "failed_edit" }
      end
    end
  end 

  def expire_data_after_sign_in!
    # session.keys will return an empty array if the session is not yet loaded.
    # This is a bug in both Rack and Rails.
    # A call to #empty? forces the session to be loaded.
    session.empty?
    session.keys.grep(/^local_devise\./).each { |k| session.delete(k) }
  end
end