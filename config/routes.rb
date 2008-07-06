ActionController::Routing::Routes.draw do |map|

  # Resources
  map.resources :commands, :collection => {:exists => :get}
  map.resources :users, :member => {:activate => :get}
  map.resource :session
  
  # Dynamic
  map.parse "/parse", :controller => 'parser', :action => 'parse'

  # Kernel
  map.man "/kernel/man", :controller => "kernel", :action => "man"
  map.connect "/kernel/man.:format", :controller => "kernel", :action => "man"

  map.most_used_commands "/kernel/most_used_commands", :controller => "kernel", :action => "most_used_commands"
  map.connect "/kernel/most_used_commands.:format", :controller => "kernel", :action => "most_used_commands"

  map.golden_eggs "/kernel/golden_eggs", :controller => "kernel", :action => "golden_eggs"
  map.connect "/kernel/golden_eggs.:format", :controller => "kernel", :action => "golden_eggs"

  map.ls "/kernel/ls", :controller => "kernel", :action => "ls"
  map.connect "/kernel/ls.:format", :controller => "kernel", :action => "ls"


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
