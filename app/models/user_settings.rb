class UserSettings < ActiveRecord::Base
  belongs_to :user
  serialize :flows, Array
end
