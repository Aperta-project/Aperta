class ResourceToken < ActiveRecord::Base
  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :owner, polymorphic: true
end
