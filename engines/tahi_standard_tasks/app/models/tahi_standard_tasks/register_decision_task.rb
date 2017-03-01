module TahiStandardTasks
  # :nodoc:
  class RegisterDecisionTask < Task
    include UrlBuilder
    DEFAULT_TITLE = 'Register Decision'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    delegate :letter_templates, to: :journal

    before_save { paper.save! }

    def after_register(decision)
      if decision.revision?
        ReviseTask.setup_new_revision(paper, phase)
        UploadManuscriptTask.setup_new_revision(paper, phase)
      end
      complete!
    end

    def send_email
      to_field = answer_for_ident(
        'register_decision_questions--to-field'
      ).try(:value)
      subject_field = answer_for_ident(
        'register_decision_questions--subject-field'
      ).try(:value)

      RegisterDecisionMailer.delay.notify_author_email(
        to_field: EmailService.new(email: to_field).valid_email_or_nil,
        subject_field: subject_field,
        decision_id: paper.decisions.completed.last.id
      )
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
