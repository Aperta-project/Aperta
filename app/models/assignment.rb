class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_to, polymorphic: true
  has_many :permissions, through: :role
  after_save do
    user.expire_cache_key
  end
end
