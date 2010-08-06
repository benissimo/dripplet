ActionController::Routing::Routes.draw do |map|
  

  map.filter :locale
  
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.resource :session
  map.resources :group_members
  map.resources :groups
  map.resources :votes
  map.resources :comments
  map.resources :water_points, :member => {:disable => :delete}
  
  map.forgot_password 'forgot_password', :controller=>"users", :action => "forgot"
  map.forgot_password_check 'forgot_password_check', :controller=>"users", :action => "forgot_check", :method => 'post'

  map.voting '/votes/toggle', :controller=> 'votes', :action => 'toggle', :method => 'post'

  map.subscribe '/followers/toggle', :controller=> 'followers', :action => 'toggle', :method => 'post'
  map.membership '/group_members/toggle', :controller=> 'group_members', :action => 'toggle', :method => 'post'
  map.message_to_group '/group/message', :controller=>'groups', :action=>'message', :method=>'post'


  map.feedback_report '/feedback/report', :controller=> 'feedback', :action => 'report'
  map.feedback_post '/feedback/deliver', :controller=> 'feedback', :action => 'deliver', :method => 'post'
  map.feedback_thanks '/feedback/thanks', :controller=>'feedback', :action => 'thanks'

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
  map.root :controller => "welcome"
  
  map.map '/map', :controller => "welcome", :action => "map"
  map.links '/links', :controller => "welcome", :action => "links"
  map.terms '/terms', :controller => "welcome", :action => "terms"
  map.story '/story', :controller => "welcome", :action => "story"
  map.netiquette '/netiquette', :controller => "welcome", :action => "netiquette"
  map.credits '/credits', :controller => "welcome", :action => "credits"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
