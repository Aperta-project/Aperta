module PlosAuthors
  class PlosAuthor < ActiveRecord::Base
    include EventStreamNotifier

    acts_as :author, dependent: :destroy
    delegate :completed?, to: :plos_authors_task, prefix: :task, allow_nil: true

    belongs_to :plos_authors_task, inverse_of: :plos_authors

    validates :affiliation, :department, :title, :email, presence: true, if: :task_completed?
    validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?

    def self.for_paper(paper)
      where(paper_id: paper)
    end
  end
end
