FiveStrikes2::Application.routes.draw do

  resources :districts


  get "frame/game"

  resources :ticker_events


  root :to => 'home#index', :as => 'home'

  devise_for :users, :controllers => { :sessions => 'local_devise/sessions',
                                       :registrations => 'local_devise/registrations',
                                       :passwords => 'local_devise/passwords',
                                       :confirmations => 'local_devise/confirmations',
                                       :omniauth_callbacks => 'local_devise/omniauth_callbacks'}

  #devise_scope :users do
  #  get '/users', :to => 'home#index', :as => :user_root
  #end

# test

  get "home/index"

  match '/home/main', :to => 'home#main'
  match '/home/game_main', :to => 'home#game_main'
  match '/home/game_statistic_main', :to => 'home#game_statistic_main'
  match '/home/game_player_main', :to => 'home#game_player_main'
  match '/home/help_info', :to => 'home#help_info'
  match '/home/side', :to => 'home#side'
  match '/home/statistic', :to => 'home#statistic'
  match '/home/statistic_home', :to => 'home#statistic_home'
  match '/home/player_statistic_detail', :to => 'home#player_statistic_detail'
  match '/line_items/create_line_items', :to => 'line_items#create_line_items'
  match '/line_items/create_team_line_items', :to => 'line_items#create_team_line_items'
  match '/line_items/create_player_line_items', :to => 'line_items#create_player_line_items'
  match '/line_items/create_game_line_items', :to => 'line_items#create_game_line_items'
  match '/facebox/fb_login' => 'facebox#fb_login', :as => :fb_login
  match '/facebox/fb_create_user' => 'facebox#fb_create_user', :as => :fb_create_user
  match '/facebox/failed_login' => 'facebox#failed_login', :as => :failed_login
  match '/facebox/fb_ask_friend' => 'facebox#fb_ask_friend', :as => :fb_ask_friend
  match '/facebox/fb_user_friends' => 'facebox#fb_user_friends', :as => :fb_user_friends
  match '/facebox/fb_find_friends' => 'facebox#fb_find_friends', :as => :fb_find_friends
  match '/facebox/fb_player_edit' => 'facebox#fb_player_edit', :as => :fb_player_edit
  match '/facebox/fb_player_new' => 'facebox#fb_player_new', :as => :fb_player_new
  match '/facebox/fb_player_csv' => 'facebox#fb_player_csv', :as => :fb_player_csv
  match '/facebox/fb_team_new' => 'facebox#fb_team_new', :as => :fb_team_new
  match '/friendships/req' => 'friendships#req', :as => :req
  match '/friendships/accept' => 'friendships#accept', :as => :req
  match '/friendships/reject' => 'friendships#reject', :as => :req
  get "users/user_friends" => "users#user_friends", :as => :user_friends
  get "users/find_friends" => "users#find_friends", :as => :find_friends
  get "users/ask_friend" => "users#ask_friend", :as => :ask_friend
  post '/multiple_ticker_activities', to: 'ticker_activities#create', as: :multiple_ticker_locations
  post '/multiple_ticker_events', to: 'ticker_events#create', as: :multiple_ticker_events_locations
  match '/impressum', to: 'home#imprint', as: :imprint
  match '/hilfe', to: 'home#help', as: :help
  match '/player_csv', to: "home#player_csv", as: :player_csv

  resources :users
  resources :ticker_activities do
    collection { post :import }
  end
  resources :participants
  resources :games
  resources :players do
    collection { post :import }
  end
  resources :teams
  resources :line_items
  resources :carts
  resources :clubs do
    collection { post :import }
  end
  resources :districts do
    collection { post :import }
  end

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create', :as => 'register'
        post 'sessions' => 'sessions#create', :as => 'login'
        delete 'sessions' => 'sessions#destroy', :as => 'logout'
      end
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
