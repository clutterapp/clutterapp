ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  
  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  
  # See how all your routes lay out with "rake routes"
  
  
  map.root :controller => 'home'
  
  
  map.login   '/sin',               :controller => 'sessions',  :action => 'create'
  map.logout  '/sout',              :controller => 'sessions',  :action => 'destroy'
  map.register '/reg',              :controller => 'users',     :action => 'create'
  #map.signup  '/signup',            :controller => 'users',     :action => 'new'
  # derived from Railscasts #124: Beta Invites <http://railscasts.com/episodes/124-beta-invites>
  map.signup '/sup/:invite_token',  :controller => 'users',     :action => 'new'
  
  
  map.resources :invites, :as => 'inv'
  
  map.resource :session
  
  map.resources :users, :has_many => :nodes
  #map.user '/:id',                :controller => 'users',    :action => 'show',      :has_many => :nodes
  
  map.resources :nodes, :belongs_to => :user, :member => {
    :move_up => :put,
    :move_down => :put,
    :move_in => :put,
    :move_out => :put,
    :update_check_prop_checked => :put,
    :set_note_prop_note => :put,
    :set_priority_prop_priority => :put,
    :set_tag_prop_tag => :put,
    :set_text_prop_text => :put,
    :set_time_prop_time => :put
  }
  
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
