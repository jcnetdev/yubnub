# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '>= 2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_blank_session',
    :secret      => 'd27cc7f3bae1ef15fa00a9fad245f42057cff6113327d732a4dbd8e43c3eaba1a5bda246f882029653b71266c2015ef38ff4ce67616d8a0b2c220884edaba8c7'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # standard gems
  config.gem "haml", :version => ">= 2.0.0"

  # ssl_requirement
  # ------
  # Allow controller actions to force SSL on specific parts of the site
  # ------
  config.gem 'jcnetdev-ssl_requirement', :version => '>= 1.0',
                                         :lib => 'ssl_requirement',
                                         :source => 'http://gems.github.com'

  # exception_notification
  # ------
  # Allows unhandled exceptions to be emailed on production
  # ------
  config.gem 'jcnetdev-exception_notification', :version => '>= 1.1',
                                                :lib => 'exception_notification',
                                                :source => 'http://gems.github.com'
  
  
  # Rails Plugins (via gems)

  # active_record_without_table
  # ------
  # Allows creation of ActiveRecord models that work without any database backend
  # ------
  config.gem 'jcnetdev-active_record_without_table', :version => '>= 1.1',
                                                     :lib => 'active_record_without_table',
                                                     :source => 'http://gems.github.com'
  
  # acts_as_state_machine
  # ------
  # Allows ActiveRecord models to define states and transition actions between them
  # ------
  config.gem 'jcnetdev-acts_as_state_machine', :version => '>= 2.1.0',
                                               :lib => 'acts_as_state_machine',
                                               :source => 'http://gems.github.com'
  
  # app_config
  # ------
  # Allow application wide configuration settings via YML files
  # ------
  config.gem 'jcnetdev-app_config', :version => '>= 1.0',
                                    :lib => 'app_config',
                                    :source => 'http://gems.github.com'
  
  # auto_migrations
  # ------
  # Allows migrations to be run automatically based on updating the schema.rb
  # ------
  config.gem 'jcnetdev-auto_migrations', :version => '>= 1.1',
                                         :lib => 'auto_migrations',
                                         :source => 'http://gems.github.com'

  # better_partials
  # ------
  # Makes calling partials in views look better and more fun
  # ------
  config.gem 'jcnetdev-better_partials', :version => '>= 1.0',
                                         :lib => 'better_partials',
                                         :source => 'http://gems.github.com'
  

  # form_fu
  # ------
  # Allows easier rails form creation and processing
  # ------
  # config.gem 'neorails-form_fu', :version => '>= 1.0',
  #                                :lib => 'form_fu',
  #                                :source => 'http://gems.github.com'
                                       
  # paperclip
  # ------
  # Allows easy uploading of files with no dependencies
  # ------
  config.gem 'jcnetdev-paperclip', :version => '>= 1.0',
                                   :lib => 'paperclip',
                                   :source => 'http://gems.github.com'
  
  # seed-fu
  # ------
  # Allows easier database seeding of tables
  # ------
  config.gem 'jcnetdev-seed-fu', :version => '>= 1.0',
                                 :lib => 'seed-fu',
                                 :source => 'http://gems.github.com'


  # subdomain-fu
  # ------
  # Allows easier subdomain selection
  # ------
  config.gem 'jcnetdev-subdomain-fu', :version => '>= 0.0.2',
                                      :lib => 'subdomain-fu',
                                      :source => 'http://gems.github.com'
  
  # validates_as_email_address
  # ------
  # Allows for easy format validation of email addresses
  # ------
  config.gem 'jcnetdev-validates_as_email_address', :version => '>= 1.0',
                                                    :lib => 'validates_as_email_address',
                                                    :source => 'http://gems.github.com'
  
  # will_paginate
  # ------
  # Allows nice and easy pagination
  # ------
  config.gem 'jcnetdev-will_paginate', :version => '>= 2.3.2',
                                       :lib => 'will_paginate',
                                       :source => 'http://gems.github.com'
  
  # view_fu
  # ------
  # Adds view helpers for titles, stylesheets, javascripts, and common tags
  # ------
  # config.gem 'neorails-view_fu', :version => '>= 1.0',
  #                                :lib => 'view_fu',
  #                                :source => 'http://gems.github.com'
  
  # OPTIONAL PLUGINS

  # acts_as_list
  # ------
  # Allows ActiveRecord Models to be easily ordered via position attributes
  # ------
  # config.gem 'jcnetdev-acts_as_list', :version => '>= 1.0',
  #                                     :lib => 'acts_as_list',
  #                                     :source => 'http://gems.github.com'

  # acts-as-readable
  # ------
  # Allows ActiveRecord Models to be easily marked as read / unread
  # ------
  # config.gem 'jcnetdev-acts-as-readable', :version => '>= 1.0',
  #                                         :lib => 'acts_as_readable',
  #                                         :source => 'http://gems.github.com'


  # sms-fu
  # ------
  # Send SMS messages easily
  # ------
  # config.gem 'jcnetdev-sms-fu', :version => '>= 1.0',
  #                               :lib => 'sms_fu',
  #                               :source => 'http://gems.github.com'

end
