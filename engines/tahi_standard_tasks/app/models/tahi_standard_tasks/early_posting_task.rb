module TahiStandardTasks
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'
    DEFAULT_ROLE_HINT = 'author'.freeze

    def task_added_to_paper(paper)
      early_posting_task = self

      card_content = CardContent.find_by!(ident: 'early-posting--consent')
      answer = early_posting_task
               .answers
               .find_or_initialize_by(card_content: card_content)
      answer.paper = paper
      answer.value = true
      answer.save!
    end
  end
end
