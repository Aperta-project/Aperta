module TahiStandardTasks
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'
    DEFAULT_ROLE = 'author'

    def self.task_added_to_workflow(early_posting_task)
      question = NestedQuestion.find_by!(ident: 'early-posting--consent')
      answer = early_posting_task.find_or_build_answer_for(nested_question: question)
      answer.value = true
      answer.save
    end
  end
end
