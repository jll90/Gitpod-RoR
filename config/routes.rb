# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    '/health', to: 
  end

  get '404', to: 'application#page_not_found'
  get '/health', to: 'application#health'
end
