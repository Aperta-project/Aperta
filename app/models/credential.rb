class Credential < ActiveRecord::Base
  include ViewableModel
  belongs_to :user, inverse_of: :credentials
end
