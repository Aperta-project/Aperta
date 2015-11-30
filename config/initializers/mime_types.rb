# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# rubocop:disable Style/LineLength
json_content_types = Mime::JSON.instance_variable_get("@synonyms")
Mime::Type.unregister(:json)
Mime::Type.register "application/json", :json, json_content_types + %w( application/json-patch+json application/vnd.api+json )
Mime::Type.register 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', :docx
Mime::Type.register "application/msword", :doc
