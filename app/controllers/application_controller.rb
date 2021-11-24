# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent

  before_action :authenticate_admin_user!, except: [:healthz]
  skip_before_action :verify_authenticity_token

  layout :determine_layout

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  def healthz
    head :ok
  end

  private

  def determine_layout
    current_admin_user ? 'application' : 'public'
  end
end
