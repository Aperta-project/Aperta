class UserFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :flows
end
