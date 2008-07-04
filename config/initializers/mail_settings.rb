# loadsmtp settings from mailer.yml
if File.exists?("#{RAILS_ROOT}/config/mailer.yml")
  yaml_contents = File.open("#{RAILS_ROOT}/config/mailer.yml") 
  ActionMailer::Base.smtp_settings = YAML.load(yaml_contents) 
end

require 'action_mailer/ar_mailer'
ActionMailer::Base.delivery_method = :activerecord
ActionMailer::ARMailer.email_class = MailOutgoing