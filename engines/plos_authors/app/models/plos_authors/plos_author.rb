module PlosAuthors
  class PlosAuthor < ActiveRecord::Base
    acts_as :author, dependent: :destroy
    delegate :completed?, to: :plos_authors_task, prefix: :task, allow_nil: true

    belongs_to :plos_authors_task, inverse_of: :plos_authors

    validates :affiliation, :corresponding, :deceased,
      :department, :title, :email, presence: true, if: :task_completed?
  end
end
