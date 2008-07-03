# set SASS overrides from app config
Sass::Plugin.options[:style] = :compact
Sass::Plugin.options.merge!(AppConfig.sass_options) if AppConfig.sass_options