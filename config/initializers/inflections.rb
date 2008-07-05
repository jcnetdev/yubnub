# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
Inflector.inflections do |inflect|
  # inflect.plural /^(ox)$/i, '\1en'
  # inflect.singular /^(ox)en/i, '\1'

  inflect.irregular 'mail_outgoing', 'mail_outgoing'
  inflect.irregular 'mail_incoming', 'mail_incoming'
end
