class Author < ActiveRecord::Base
  actable

  belongs_to :author_group, inverse_of: :authors
  acts_as_list scope: :author_group

  validates :author_group, presence: true

  def formatted_errors
    self.errors.to_h.merge(id: self.id)
  end
end
