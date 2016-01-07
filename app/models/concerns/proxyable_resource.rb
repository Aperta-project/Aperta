# provides proxy urls for any resource that might need them
module ProxyableResource
  extend ActiveSupport::Concern
  include UrlBuilder

  # makes a non expiring proxy url
  # version:
  #   is a attachment version (size) in carrierwave (:detail, :preview, etc)
  # only_path
  #   allows for relative urls
  def non_expiring_proxy_url(version: nil, only_path: true)
    options = { resource: self.class.to_s.underscore.pluralize,
                token: token,
                version: version,
                only_path: only_path }
    url_for(:resource_proxy, options)
  end

  # a convenience method that can be conditionally proxied or not proxied
  # determined by is_proxied argument
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

  def expiring_s3_url(version)
    # unfortunately attachment.ur(nil) fails, so can't be 'defaulted'
    version ? attachment.url(version) : attachment.url
  end
end
