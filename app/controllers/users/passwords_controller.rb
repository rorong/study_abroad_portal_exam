# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  before_action :set_current_agency
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private
    
    def set_current_agency
      subdomain = request.subdomains.first
      if subdomain
        agency = Agency.find_by(subdomain: subdomain)
        if agency
          puts "-- Tenant set ------ #{agency.subdomain}"
          ActsAsTenant.current_tenant = agency
        else
          raise ActsAsTenant::Errors::NoTenantSet unless agency
          # redirect_to root_url(subdomain: nil), alert: "Agency not found"
        end
      else
        raise ActsAsTenant::Errors::NoTenantSet unless agency
        # redirect_to root_url(subdomain: nil), alert: "No subdomain provided"
      end
    end

    def current_agency
      ActsAsTenant.current_tenant
    end
end
