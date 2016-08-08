class Withdrawal < ActiveRecord::Base
  belongs_to :paper
  belongs_to :withdrawn_by_user, class_name: 'User'

  validates :paper, presence: true

  def self.most_recent
    order('id DESC').first
  end
end
