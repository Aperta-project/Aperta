module StandardTasks
  class RegisterDecisionTask < Task

    # TODO: move these attributes from paper to this task model (https://www.pivotaltracker.com/story/show/84690814)
    delegate :decision, :decision=, :decision_letter, :decision_letter=, to: :paper, prefix: :paper
    before_save { paper.save! }

    def self.permitted_attributes
      super + [:paper_decision, :paper_decision_letter]
    end

    register_task default_title: "Register Decision", default_role: "editor"

    def after_update
      make_paper_editable
      # ultimately, we can call #send_emails here as well

      create_please_revise_card!
    end

    def make_paper_editable
      return unless revise_decision?
      self.paper.update! editable: true
    end

    def send_emails
      return unless on_card_completion?
      RegisterDecisionMailer.delay.notify_author_email(task_id: id)
    end

    def accept_letter
      template = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        I am pleased to inform you that your manuscript, %{manuscript_title}, has been deemed suitable for publication in %{journal_name}. Congratulations!

        Your manuscript will now be passed on to our Production staff, who will check your files for correct formatting and completeness. During this process, you may be contacted to make necessary alterations to your manuscript, though not all manuscripts require this.

        If you or your institution will be preparing press materials for this manuscript, you must inform our press team in advance. Your manuscript will remain under a strict press embargo until the publication date and time.

        Please contact me if you have any other questions or concerns. Thank you for submitting your work to PLOS ONE.

        With kind regards,

        %{ae_full_name}
        Academic Editor
        %{journal_name}
      TEXT

      template % template_data
    end

    def revise_letter
      template = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title} to %{journal_name}. After careful consideration, we feel that it has merit, but is not suitable for publication as it currently stands. Therefore, my decision is "Major Revision."

        We invite you to submit a revised version of the manuscript that addresses the points below:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING WHICH REVIEWER COMMENTS MUST BE ADDRESSED.

        ***

        We encourage you to submit your revision within forty-five days of the date of this decision.

        When your files are ready, please submit your revision by logging on to tahi-staging.herokuapp.com and following the instructions for resubmission. Do not submit a revised manuscript as a new submission.

        If you choose not to submit a revision, please notify us.

        Yours sincerely,

        %{ae_full_name}
        Academic Editor
        %{journal_name}
      TEXT

      template % template_data
    end

    def reject_letter
      template = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title}, to %{journal_name}. After careful consideration, we have decided that your manuscript does not meet our criteria for publication and must therefore be rejected.

        Specifically:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING HOW THE MANUSCRIPT DOES NOT MEET OUR PUBLICATION CRITERIA.

        ***

        I am sorry that we cannot be more positive on this occasion, but hope that you appreciate the reasons for this decision.

        Yours sincerely,

        %{ae_full_name}
        Academic Editor
        %{journal_name}
      TEXT

      template % template_data
    end

    private

    def create_please_revise_card!
      return unless revise_decision?

      TaskFactory.build(Task,
        title: "Please Revise",
        role: "user",
        phase_id: phase.id,
        body: [[{type: 'text', value: revise_letter}]]
      ).save!
    end

    def revise_decision?
      on_card_completion? && paper.decision == 'revise'
    end

    def template_data
      paper_editor = paper.editor
      editor_name = paper_editor.present? ? paper_editor.full_name : "***\nEditor not assigned\n***"
      { author_last_name: paper.creator.last_name,
        manuscript_title: paper.title,
        journal_name: paper.journal.name,
        ae_full_name: editor_name }
    end
  end
end
