module TahiStandardTasks
  class RegisterDecisionTask < Task
    include UrlBuilder
    DEFAULT_TITLE = 'Register Decision'
    DEFAULT_ROLE = 'editor'

    # TODO: move these attributes from paper to this task model (https://www.pivotaltracker.com/story/show/84690814)
    delegate :decision_letter, :decision_letter=, to: :paper, prefix: :paper
    before_save { paper.save! }

    def self.permitted_attributes
      super + [:paper_decision_letter]
    end

    def latest_decision
      paper.decisions.latest
    end

    def latest_decision_ready?
      latest_decision.present? && latest_decision.verdict.present?
    end

    def complete_decision
      decision = latest_decision
      paper.make_decision decision
      # If it's a revise decision, prepare a new decision task.
      DecisionReviser.new(self, decision).process! if decision.revision?
    end

    def send_email
      RegisterDecisionMailer.delay.notify_author_email(
        decision_id: paper.decisions.completed.latest)
    end

    def send_emails
    end

    # These methods are a bunch of english text. They should be moved to
    # their own file, but we're not sure where. They're here, instead of a
    # mailer template, because users can edit the text before it gets
    # sent out.
    # rubocop:disable Metrics/LineLength
    def accept_templates
      template = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        I am pleased to inform you that your manuscript, %{manuscript_title}, has been deemed suitable for publication in %{journal_name}. Congratulations!

        Your manuscript will now be passed on to our Production staff, who will check your files for correct formatting and completeness. During this process, you may be contacted to make necessary alterations to your manuscript, though not all manuscripts require this.

        If you or your institution will be preparing press materials for this manuscript, you must inform our press team in advance. Your manuscript will remain under a strict press embargo until the publication date and time.

        Please contact me if you have any other questions or concerns. Thank you for submitting your work to %{journal_name}.

        With kind regards,

        %{your_name}
        %{journal_name}
      TEXT

      replaced_template = template % template_data
      [{ template_name: 'accept', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: replaced_template }]
    end

    def minor_revision_templates
      template = <<-TEXT.strip_heredoc
        THIS IS THE MINOR REVISION
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title} to %{journal_name}. After careful consideration, we feel that it has merit, but is not suitable for publication as it currently stands. Therefore, my decision is "Minor Revision."

        We invite you to submit a revised version of the manuscript that addresses the points below:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING WHICH REVIEWER COMMENTS MUST BE ADDRESSED.

        ***

        We encourage you to submit your revision within forty-five days of the date of this decision.

        When your files are ready, please submit your revision by logging on to #{url_for(:root)} and following the instructions for resubmission. Do not submit a revised manuscript as a new submission.

        If you choose not to submit a revision, please notify us.

        Yours sincerely,

        %{your_name}
        %{journal_name}
      TEXT

      replaced_template = template % template_data
      [{ template_name: 'minor revision', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: replaced_template }]
    end

    def major_revision_templates
      template = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title} to %{journal_name}. After careful consideration, we feel that it has merit, but is not suitable for publication as it currently stands. Therefore, my decision is "Major Revision."

        We invite you to submit a revised version of the manuscript that addresses the points below:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING WHICH REVIEWER COMMENTS MUST BE ADDRESSED.

        ***

        We encourage you to submit your revision within forty-five days of the date of this decision.

        When your files are ready, please submit your revision by logging on to #{url_for(:root)} and following the instructions for resubmission. Do not submit a revised manuscript as a new submission.

        If you choose not to submit a revision, please notify us.

        Yours sincerely,

        %{your_name}
        %{journal_name}
      TEXT

      replaced_template = template % template_data
      [{ template_name: 'major revision', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: replaced_template }]
    end

    def reject_templates
      template1 = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title}, to %{journal_name}. After careful consideration, we have decided that your manuscript does not meet our criteria for publication and must therefore be rejected.

        Specifically:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING HOW THE MANUSCRIPT DOES NOT MEET OUR PUBLICATION CRITERIA.

        ***

        I am sorry that we cannot be more positive on this occasion, but hope that you appreciate the reasons for this decision.

        Yours sincerely,

        %{your_name}
        %{journal_name}
      TEXT

      template2 = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title}, to %{journal_name}. After careful consideration, we have decided that your manuscript does not meet our criteria for publication and must therefore be rejected.

        Specifically:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING HOW THE MANUSCRIPT DOES NOT MEET OUR PUBLICATION CRITERIA.

        ***

        I am sorry that we cannot be more positive on this occasion, but hope that you appreciate the reasons for this decision.

        Yours sincerely,

        %{your_name}
        %{journal_name}
      TEXT

      template3 = <<-TEXT.strip_heredoc
        Dear Dr. %{author_last_name},

        Thank you for submitting your manuscript, %{manuscript_title}, to %{journal_name}. After careful consideration, we have decided that your manuscript does not meet our criteria for publication and must therefore be rejected.

        Specifically:

        ***

        ACADEMIC EDITOR:

        PLEASE INSERT COMMENTS HERE GIVING CONTEXT TO THE REVIEWS AND EXPLAINING HOW THE MANUSCRIPT DOES NOT MEET OUR PUBLICATION CRITERIA.

        ***

        I am sorry that we cannot be more positive on this occasion, but hope that you appreciate the reasons for this decision.

        Yours sincerely,

        %{your_name}
        %{journal_name}
      TEXT

      one = template1 % template_data
      two = template2 % template_data
      three = template3 % template_data
      [{ template_name: 'reject 1', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: one },
       { template_name: 'reject 2', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: two },
       { template_name: 'reject 3', to: '%{author_email}', subject: "Your #{journal_name} Submission", letter: three }]
    end
    # rubocop:enable Metrics/LineLength

    private

    def journal_name
      @journal_name ||= paper.journal.name
    end

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
