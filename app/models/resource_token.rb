# ResourceToken is a class to link internal models to external resources. It is
# used to when we want to hand out a permalink for an asset that is hosted on S3
# that requires a temporary signed url.
class ResourceToken < ActiveRecord::Base
  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :owner, polymorphic: true
end
