# provides proxy urls for any resource that might need them
module ProxyableResource
  extend ActiveSupport::Concern
  include UrlBuilder

  included do
    # This creates the token used by resource proxy to lookup the attachment.

    has_many :resource_tokens, as: :owner
    delegate :token, to: :resource_token
  end

  def resource_token
    resource_tokens.order('created_at DESC').first
  end

  # makes a non expiring proxy url
  # version:
  #   is a file version (size) in carrierwave (:detail, :preview, etc)
  # only_path
  #   allows for relative urls
  def non_expiring_proxy_url(version: nil, only_path: true, cache_buster: false)
    options = { token: resource_token.token,
                version: version,
                only_path: only_path }
    options[:cb] = cache_buster_value if cache_buster
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

  def cache_buster_value
    # This will over-aggressively invalidate file caches as it will create
    # a new cache buster for changes having nothing to do with the file
    # content. If we want to bust more intelligently, we can ask S3 for an etag
    # for the file, or keep track of a file checksum or file_updated_at in the
    # db. Both have downsides that may not be worth the feature.
    updated_at.to_i
  end

  def expiring_s3_url(version)
    # unfortunately file.ur(nil) fails, so can't be 'defaulted'
    version ? file.url(version) : file.url
  end
end
