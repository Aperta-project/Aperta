module TahiStandardTasks
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'
    DEFAULT_ROLE = 'author'
    DEFAULT_ROLE_HINT = 'author'.freeze

    def task_added_to_paper(paper)
      early_posting_task = self

      question = NestedQuestion.find_by!(ident: 'early-posting--consent')
      answer = early_posting_task.find_or_build_answer_for(nested_question: question)
      answer.value = true
      answer.save!
    end
  end
end
