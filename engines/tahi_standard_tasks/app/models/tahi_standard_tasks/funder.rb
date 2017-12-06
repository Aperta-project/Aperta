module TahiStandardTasks
  class Funder < ActiveRecord::Base
    include Answerable

    belongs_to :task, foreign_key: :task_id

    # NestedQuestionAnswersController will save the paper_id to newly created
    # answers if an answer's owner responds to :paper. This method is needed by
    # the NestedQuestionAnswersController#fetch_answer method, among others
    def paper
      task.paper
    end
  end
end
