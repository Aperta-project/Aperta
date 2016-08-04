module TahiStandardTasks
  class RegisterDecisionTask < Task
    include UrlBuilder
    DEFAULT_TITLE = 'Register Decision'
    DEFAULT_ROLE = 'editor'

    # TODO: move these attributes from paper to this task model (https://www.pivotaltracker.com/story/show/84690814)
    delegate :decision_letter, :decision_letter=, to: :paper, prefix: :paper

    delegate :letter_templates, to: :journal

    before_save { paper.save! }

    def self.permitted_attributes
      super + [:paper_decision_letter]
    end

    def after_register(decision)
      ReviseTask.setup_new_revision(paper, phase) if decision.revision?
      complete!
    end

    def send_email(to_field:, subject_field:)
      RegisterDecisionMailer.delay.notify_author_email(
        to_field: EmailService.new(email: to_field).valid_email_or_nil,
        subject_field: subject_field,
        decision_id: paper.decisions.completed.last)
    end

    private

    def template_data
      {
        author_last_name: paper.creator.last_name,
        manuscript_title: paper.display_title(sanitized: false),
        journal_name: paper.journal.name,
        your_name: '[YOUR NAME]'
      }
    end
  end
end
