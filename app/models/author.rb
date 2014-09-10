class Author < ActiveRecord::Base
  belongs_to :author_group, inverse_of: :authors
  belongs_to :custom_author, polymorphic: true
  acts_as_list scope: :author_group

  validates :author_group, presence: true

  # for now, this is a simple way to bubble errors up to Author
  accepts_nested_attributes_for :custom_author
  validates_associated :custom_author
end
