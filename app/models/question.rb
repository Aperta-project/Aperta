class Question < ActiveRecord::Base
  belongs_to :task

  validates :ident, presence: true
end
