module PlosAuthors
  class PlosAuthor < ActiveRecord::Base
  include EventStream::Notifiable

    acts_as :author, dependent: :destroy
    delegate :completed?, to: :plos_authors_task, prefix: :task, allow_nil: true

    serialize :contributions, Array

    belongs_to :plos_authors_task, inverse_of: :plos_authors


    validates :first_name, :last_name, :affiliation, :department, :title, :email, presence: true, if: :task_completed?
    validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?
    validates :contributions, presence: { message: "one must be selected" }, if: :task_completed?

    def self.for_paper(paper)
      where(paper_id: paper)
    end

    def event_stream_serializer(user)
      PlosAuthorsSerializer.new(plos_authors_task.plos_authors, user: user, root: :plos_authors)
    end
  end
end
