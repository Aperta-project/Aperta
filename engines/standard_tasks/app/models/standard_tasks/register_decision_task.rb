module StandardTasks
  class RegisterDecisionTask < Task
    def permitted_attributes
      super + [:paper_decision, :paper_decision_letter]
    end

    register_task default_title: "Register Decision", default_role: "editor"

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

    def paper_decision
      paper.decision
    end

    def paper_decision=(decision)
      paper.update(decision: decision)
    end

    def paper_decision_letter
      paper.decision_letter
    end

    def paper_decision_letter=(body)
      paper.update(decision_letter: body)
    end

    private

    def template_data
      paper_editor = paper.editor
      editor_name = paper_editor.present? ? paper_editor.full_name : "***\nEditor not assigned\n***"
      { author_last_name: paper.user.last_name,
        manuscript_title: paper.title,
        journal_name: paper.journal.name,
        ae_full_name: editor_name }
    end
  end
end
