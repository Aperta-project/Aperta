class AuthorListItem < ActiveRecord::Base
  acts_as_list scope: :task

  belongs_to :task, class_name: "TahiStandardTasks::AuthorsTask"
  belongs_to :author, polymorphic: true
end
