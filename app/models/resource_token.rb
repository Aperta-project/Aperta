# ResourceToken is a class to link internal models to external resources. It is
# used to when we want to hand out a permalink for an asset that is hosted on S3
# that requires a temporary signed url.
class ResourceToken < ActiveRecord::Base
  include ViewableModel
  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :owner, polymorphic: true

  def url(version = nil)
    chosen_url = default_url
    chosen_url = version_urls[version.to_s] if version
    if chosen_url
      owner_type.constantize.authenticated_url_for_key(chosen_url)
    end
  end
end
