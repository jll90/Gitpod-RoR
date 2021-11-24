# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    get '/health', to: 'api#health'
  end

  get '404', to: 'application#page_not_found'
  get '/health', to: 'application#health'
end
