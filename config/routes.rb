ActionController::Routing::Routes.draw do |map|

  # Resources
  map.resources :commands, :collection => {:exists => :get}
  map.resources :users, :member => {:activate => :get}
  map.resource :session
  
  # Dynamic
  map.parse "/parse", :controller => 'parser', :action => 'parse'
  map.commands "/commands", :controller => 'kernel', :action => 'most_used_commands'


  # Pages
  map.syntax "/syntax", :controller => 'pages', :action => 'describe_advanced_syntax'
  map.install "/install", :controller => 'pages', :action => 'describe_installation'
  map.ack "/acknowledgements", :controller => 'pages', :action => 'display_acknowledgements'
  map.picks "/picks", :controller => 'pages', :action => 'jeremys_picks'
  map.upcoming "/upcoming", :controller => 'pages', :action => 'describe_upcoming_features'

  
  # Old Routes
  map.connect "/command/new", :controller => "commands", :action => "new"

  # sample resource
  map.root :controller => "parser", :action => "landing"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
