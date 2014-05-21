class Credential < ActiveRecord::Base
  belongs_to :user, inverse_of: :credentials
end
