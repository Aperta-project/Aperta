class AuthorListItem < ActiveRecord::Base
  acts_as_list

  belongs_to :task, polymorphic: true
  belongs_to :author, polymorphic: true
end
