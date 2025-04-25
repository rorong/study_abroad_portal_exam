# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :set_current_agency
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
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
