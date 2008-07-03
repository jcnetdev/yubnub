require 'haml/engine'
require 'rubygems'
require 'active_support'
require 'action_view'

module Haml
  class Template
    class << self
      @@options = {}

      # Gets various options for Haml. See README for details.
      def options
        @@options
      end

      # Sets various options for Haml. See README for details.
      def options=(value)
        @@options = value
      end
    end
  end
end

# Decide how we want to load Haml into Rails.
# Patching was necessary for versions <= 2.0.1,
# but we can make it a normal handler for higher versions.
if defined?(ActionView::TemplateHandler)
  require 'haml/template/plugin'
else
  require 'haml/template/patch'
end

if defined?(RAILS_ROOT)
  # Update init.rb to the current version
  # if it's out of date.
  #
  # We can probably remove this as of v1.9,
  # because the new init file is sufficiently flexible
  # to not need updating.
  rails_init_file = File.join(RAILS_ROOT, 'vendor', 'plugins', 'haml', 'init.rb')
  haml_init_file = File.join(File.dirname(__FILE__), '..', '..', 'init.rb')
  if File.exists?(rails_init_file)
    require 'fileutils'
    FileUtils.cp(haml_init_file, rails_init_file) unless FileUtils.cmp(rails_init_file, haml_init_file)
  end
end
