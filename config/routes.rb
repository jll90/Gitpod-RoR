# frozen_string_literal: true

Rails.application.routes.draw do
  # resources :update_requests
  # resources :app_experiences
  # resources :categories
  devise_for :admin_users, path: 'admin',
                           path_names: { sign_in: 'login',
                                         sign_out: 'logout',
                                         sign_up: '',
                                         registration: '',
                                         edit: 'edit',
                                         cancel: 'cancel',
                                         confirmation: 'verification' }
  root to: 'landing#index'
  # ADMIN
  namespace :admin do
    get '/' => 'home#index'
    resources :matches, only: :index
    resources :products, only: %i[index show] do
      put 'toggle_state/:state' => 'products#toggle_state'
      delete 'remove_image/:image_id' => 'products#remove_image'
    end
    resources :swipes, only: :index
    resources :users, only: %i[index show]
  end

  namespace :api do
    resources :update_requests, only: %i[create update]
    resources :app_experiences, only: %i[create]
    resources :categories, only: %i[index]

    # PROFILE
    patch 'profiles/self' => 'api#edit_user'
    get 'profiles/self' => 'profiles#own_profile'

    # CREDENTIALS
    post 'signup' => 'api#signup'

    post 'login' => 'api#login'
    post 'forgot' => 'api#forgot_password'
    post 'reset' => 'api#reset_password'
    post 'sessions/code' => 'sessions#request_login_code'
    post 'sessions/validate' => 'sessions#validate_login_code'
    put 'notification_tokens' => 'api#device_token'
    delete 'logout/:id' => 'api#logout'

    #  SWIPES
    get 'swipes/self' => 'swipes#index_self'
    put 'swipes' => 'swipes#upsert'

    #  NOTIFICATIONS
    get 'notifications/unread' => 'notifications#unread'
    get 'notifications' => 'notifications#index'

    # MATCHES
    get 'matches/self' => 'matches#can_pay_matches'
    get 'matches/:id' => 'matches#show'
    get 'matches/:id/unlock' => 'matches#unlock'
    get 'sent_likes/self' => 'matches#user_requested_matches'
    get 'received_likes/self' => 'matches#user_matches'
    patch 'matches/:id/mark_as_read' => 'matches#mark_as_read'
    patch 'matches/:id/:state' => 'matches#update_state'
    get 'requested_matches/self' => 'api#user_requested_matches'

    # PRODUCTS
    get 'discover/self' => 'api#user_discover'
    post 'discover/discard' => 'api#discard_discovered_product'
    post 'products' => 'products#create'
    get 'products/:product_id/questions' => 'questions#index_for_product'
    post 'products/:product_id/questions' => 'questions#create'
    patch 'products/:id' => 'products#update'

    patch 'questions/:id/read' => 'questions#mark_as_read'
    get 'questions/self' => 'questions#index_for_user'
    get 'questions/:id' => 'questions#show'
    get 'replies' => 'replies#index'
    patch 'replies/:reply_id/reply_receipts' => 'reply_receipts#update'
    post 'questions/:question_id/replies' => 'replies#create'
    delete 'questions/:question_id/replies/:reply_id' => 'products#delete_reply'
    get 'products/self' => 'products#user_products'
    get 'products/for_match' => 'products#match_candidate_products'
    get 'products/discover' => 'products#user_discover'
    get 'products/:id/self' => 'products#show_self'
    patch 'products/:id/archive' => 'products#archive'
    patch 'products/:id/reset' => 'products#reset' if Rails.env.development?
    delete 'products/:id' => 'products#destroy'
    delete 'swipes/dislikes' => 'swipes#destroy_dislikes'
  end

  # MISC
  get '404', to: 'application#page_not_found'
  get '/healthz', to: 'application#healthz'
end
