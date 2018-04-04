class Assignment < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_to, polymorphic: true
  has_many :permissions, through: :role
  after_commit :bust_cache

  def bust_cache
    # deletes cache from UserHelper#can?
    Rails.cache.delete_matched(/^user_#{user.id}_can/)
  end
end
