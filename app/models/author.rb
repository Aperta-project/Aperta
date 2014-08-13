class Author < ActiveRecord::Base
  belongs_to :author_group, inverse_of: :authors
  acts_as_list scope: :author_group

  validates :position, presence: true
  validates :author_group, presence: true

  def mark_for_validation(*args, options)
    self.class_eval do
      validates *args, options
    end
  end

  def formatted_errors
    self.errors.to_h.merge(id: self.id)
  end
end
