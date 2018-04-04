class Assignment < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_to, polymorphic: true
  has_many :permissions, through: :role
  after_commit ->(model) { model.user.bust_can_cache }
end
