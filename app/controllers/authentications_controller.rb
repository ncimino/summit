class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
      omniauth = request.env["omniauth.auth"]
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      if authentication
        flash[:info] = "Signed in successfully."
        sign_in_and_redirect(:user, authentication.user)
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        flash[:info] = "Authentication successful."
        redirect_to authentications_url
      else
        user = User.new
        user.apply_omniauth(omniauth)
        if user.save
          flash[:info] = "Signed in successfully."
          sign_in_and_redirect(:user, user)
        else
          session[:omniauth] = omniauth.except('extra')
          redirect_to new_user_registration_url
        end
      end
  end

  def failure
    flash[:error] = "There was a problem authenticating with the selected service."
    redirect_to new_user_registration_url
  end

  def destroy
    if ( current_user.authentications.count == 1 && current_user.encrypted_password.empty? )
      flash[:error] = "You must first set a password on the <a href=\"#{edit_user_registration_path}\">preferences page</a>".html_safe
    else
      @authentication = current_user.authentications.find(params[:id])
      @authentication.destroy
      flash[:success] = "Successfully destroyed authentication."
    end
    redirect_to authentications_url
  end

  protected

  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  def handle_unverified_request
    true
  end

end
