module StandardTasks
  class AwesomeAuthor < ActiveRecord::Base
    belongs_to :awesome_authors_task, inverse_of: :awesome_authors
    acts_as :author, dependent: :destroy

    validates :awesome_name, presence: true, if: :task_completed

    def formatted_errors
      self.errors.to_h.merge(id: self.id)
    end

    private

    def task_completed
      awesome_authors_task.completed?
    end
  end
end
