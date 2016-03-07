class AuthorListItem < ActiveRecord::Base
  acts_as_list

  belongs_to :task, class_name: "TahiStandardTasks::AuthorsTask"
  belongs_to :author, polymorphic: true
end
