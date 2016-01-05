# Generates URLs from resource names using Rails routes
# Can be mixed into ActiveRecord models to generate URLs
#
# Uses the host and port defined in the environment config file.
#
module UrlBuilder
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  # Given a resource_name (e.g., :root), return the
  # corresponding url (e.g., "http://www.example.com/")
  #
  def url_for(resource_name, options = {})
    rails_routing_options = { host: host, port: port }.merge(options)
    url_helpers.send("#{resource_name}_url", rails_routing_options)
  end

  private

  def host
    Rails.configuration.action_mailer.default_url_options[:host] || 'nohost'
  end

  def port
    Rails.configuration.action_mailer.default_url_options[:port]
  end
end
