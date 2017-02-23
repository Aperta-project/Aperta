module TahiStandardTasks
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'
    DEFAULT_ROLE_HINT = 'author'.freeze

    def task_added_to_paper(paper)
      question = CardContent.for_journal(paper.journal).find_by!(ident: 'early-posting--consent')

      answer = question.answers.find_or_initialize_by(owner: self)
      answer.value = true
      answer.save!
    end
  end
end
