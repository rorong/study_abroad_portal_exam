# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    # You should also create an action method in this controller like this:
    # def twitter
    # end

    # def google_oauth2
    #   user = User.from_omniauth(auth)

    #   if user.present?
    #     sign_out_all_scopes
    #     flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
    #     sign_in_and_redirect user, event: :authentication
    #   else
    #     flash[:errors] =
    #       t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
    #     redirect_to new_user_session_path
    #   end
    # end

    # def facebook
    #   user = User.from_omniauth(auth)
    
    #   if user.present?
    #     sign_out_all_scopes
    #     flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Facebook'
    #     sign_in_and_redirect user, event: :authentication
    #   else
    #     flash[:errors] =
    #       t 'devise.omniauth_callbacks.failure', kind: 'Facebook', reason: "#{auth.info.email} is not authorized."
    #     redirect_to new_user_session_path
    #   end
    # end    

    # More info at:
    # https://github.com/heartcombo/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end

    # protected

    # def after_omniauth_failure_path_for(_scope)
    #   new_user_session_path
    # end

    # def after_sign_in_path_for(resource_or_scope)
    #   stored_location_for(resource_or_scope) || root_path
    # end

    # private

    # def from_google_params
    #   @from_google_params ||= {
    #     uid: auth.uid,
    #     email: auth.info.email,
    #     full_name: auth.info.name,
    #     avatar_url: auth.info.image
    #   }
    # end

    # def auth
    #   debugger
    #   @auth ||= request.env['omniauth.auth']
    # end
    def google_oauth2
      user = User.from_omniauth(request.env["omniauth.auth"])

      if user.persisted?
        sign_in_and_redirect user, event: :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
      end
    end

    def failure
      redirect_to root_path, alert: "Authentication failed, please try again."
    end
  end
end
