# frozen_string_literal: true

class LandingController < ApplicationController
  before_action :authenticate_admin_user!, except: [:index]

  def index
    render 'landing/index'
  end
end
