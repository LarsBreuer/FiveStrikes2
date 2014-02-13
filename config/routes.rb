FiveStrikes2::Application.routes.draw do
  
  root :to => 'home#index', :as => 'home'

  devise_for :users, :controllers => { :sessions => 'local_devise/sessions', 
                                       :registrations => 'local_devise/registrations', 
                                       :passwords => 'local_devise/passwords', 
                                       :confirmations => 'local_devise/confirmations', 
                                       :omniauth_callbacks => 'local_devise/omniauth_callbacks'}
  
  #devise_scope :users do
  #  get '/users', :to => 'home#index', :as => :user_root
  #end 

  get "home/index"

  match '/home/main', :to => 'home#main' 
  match '/home/statistic', :to => 'home#statistic' 
  match '/home/statistic_home', :to => 'home#statistic_home' 
  match '/Facebox/fb_login' => 'facebox#fb_login', :as => :fb_login
  match '/Facebox/fb_create_user' => 'facebox#fb_create_user', :as => :fb_create_user
  match '/Facebox/failed_login' => 'facebox#failed_login', :as => :failed_login
  match '/Facebox/fb_ask_friend' => 'facebox#fb_ask_friend', :as => :fb_ask_friend
  match '/Facebox/fb_user_friends' => 'facebox#fb_user_friends', :as => :fb_user_friends
  match '/Facebox/fb_find_friends' => 'facebox#fb_find_friends', :as => :fb_find_friends
  match '/friendships/req' => 'friendships#req', :as => :req
  match '/friendships/accept' => 'friendships#accept', :as => :req
  match '/friendships/reject' => 'friendships#reject', :as => :req
  get "users/user_friends" => "users#user_friends", :as => :user_friends
  get "users/find_friends" => "users#find_friends", :as => :find_friends
  get "users/ask_friend" => "users#ask_friend", :as => :ask_friend

  resources :users

  resources :tickers

  resources :participants

  resources :games

  resources :players

  resources :teams

  
  
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
