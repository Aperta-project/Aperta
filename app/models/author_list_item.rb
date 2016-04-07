class AuthorListItem < ActiveRecord::Base
  acts_as_list scope: :paper

  belongs_to :paper
  belongs_to :author, polymorphic: true, dependent: :destroy
end
