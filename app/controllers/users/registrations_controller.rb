# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_current_agency
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private
    
    def set_current_agency
      agency = Agency.first
      ActsAsTenant.current_tenant = agency
      # subdomain = request.subdomains.first
      # if subdomain
      #   agency = Agency.find_by(subdomain: subdomain)
      #   if agency
      #     puts "-- Tenant set ------ #{agency.subdomain}"
      #     ActsAsTenant.current_tenant = agency
      #   else
      #     raise ActsAsTenant::Errors::NoTenantSet unless agency
      #     # redirect_to root_url(subdomain: nil), alert: "Agency not found"
      #   end
      # else
      #   raise ActsAsTenant::Errors::NoTenantSet unless agency
      #   # redirect_to root_url(subdomain: nil), alert: "No subdomain provided"
      # end
    end

    def current_agency
      ActsAsTenant.current_tenant
    end
end
