# provides proxy urls for any resource that might need them
#
# non_expiring_proxy_url:
#   an explicit method to make a
#   needs to have one
#
# proxyable_url:
#   a convenience method that can be conditionally proxyable via
#   is_proxied argument
#
module ProxyableResource
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def non_expiring_proxy_url(version: nil, only_path: true)
    url_helpers
      .resource_proxy_url resource: self.class.to_s.underscore.pluralize,
                          token: token,
                          version: version,
                          only_path: only_path,
                          host: host,
                          port: port
  end

  def proxyable_url(version: nil, is_proxied: false, only_path: true)
    # note: <img src/> must NOT be proxied for pdf, since it gets embeded
    # at create time
    if is_proxied
      non_expiring_proxy_url(version: version, only_path: only_path)
    else
      expiring_s3_url(version)
    end
  end

  private

  def host
    Rails.configuration.action_mailer.default_url_options[:host] || 'nohost'
  end

  def port
    Rails.configuration.action_mailer.default_url_options[:port]
  end

  def expiring_s3_url(version)
    # unfortunately attachment.ur(nil) fails, so can't be 'defaulted'
    version ? attachment.url(version) : attachment.url
  end
end
