class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :journal
end
