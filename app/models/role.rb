class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
end
