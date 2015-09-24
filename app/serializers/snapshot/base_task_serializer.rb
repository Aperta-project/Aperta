module Snapshot
  class BaseTaskSerializer < BaseSerializer

    def initialize(task)
      @task = task
    end

    def snapshot_nested_questions
      nested_questions = []
      @task.nested_questions.each do |nested_question|
        nested_question_answer.find(task: task, parent_id: nil, nested_question: nested_question)


        #nested_questions << nested_question_answer
      end
    end

    def snapshot_nested_question nested_question
      children = NestedQuestion.where(task: task, )
    end
  end
end
