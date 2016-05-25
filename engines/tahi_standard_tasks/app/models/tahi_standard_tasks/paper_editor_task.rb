module TahiStandardTasks
  class PaperEditorTask < Task
    include ClientRouteHelper
    include Rails.application.routes.url_helpers
    DEFAULT_TITLE = 'Invite Academic Editor'
    DEFAULT_ROLE = 'admin'

    include Invitable

    def academic_editors
      paper.academic_editors
    end

    def invitation_invited(invitation)
      invitation.save!
      PaperEditorMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      add_invitee_as_academic_editor_on_paper!(invitation)
      PaperAdminMailer.delay.notify_admin_of_editor_invite_accepted(
        paper_id:  invitation.paper.id,
        editor_id: invitation.invitee.id
      )
    end

    def invitee_role
      Role::ACADEMIC_EDITOR_ROLE
    end

    def invitation_template
      LetterTemplate.new(
        salutation: "Dear Dr. [EDITOR NAME],",
        body: invitation_body
      )
    end

    private

    # This method is a bunch of english text. It should be moved to
    # its own file, but we're not sure where. It's here, instead of a
    # mailer template, because users can edit the text before it gets
    # sent out.
    # rubocop:disable Metrics/LineLength, Metrics/MethodLength
    def invitation_body
      template = <<-TEXT.strip_heredoc
        I am writing to seek your advice as the academic editor on a manuscript entitled '%{manuscript_title}'. The corresponding author is %{author_name}, and the manuscript is under consideration at %{journal_name}.

        We would be very grateful if you could let us know whether or not you are able to take on this assignment within 24 hours, so that we know whether to await your comments, or if we need to approach someone else. To accept or decline the assignment via our submission system, please use the link below. If you are available to help and have no conflicts of interest, you also can view the entire manuscript via this link.

        <a href="%{dashboard_url}">View Invitation</a>

        If you do take this assignment, and think that this work is not suitable for further consideration by PLOS Biology, please tell us if it would be more appropriate for one of the other PLOS journals, and in particular, PLOS ONE (<a href="http://plos.io/1hPjumI">http://plos.io/1hPjumI</a>). If you suggest PLOS ONE, please let us know if you would be willing to act as Academic Editor there. For more details on what this role would entail, please go to <a href="http://journals.plos.org/plosone/s/journal-information ">http://journals.plos.org/plosone/s/journal-information</a>.

        I have appended further information, including a copy of the abstract and full list of authors below.

        My colleagues and I are grateful for your support and advice. Please don't hesitate to contact me should you have any questions.

        Kind regards,
        [YOUR NAME]
        %{journal_name}

        ***************** CONFIDENTIAL *****************

        Manuscript Title:
        %{manuscript_title}

        Authors:
        %{authors}

        Abstract:
        %{abstract}

        To view this manuscript, please use the link presented above in the body of the e-mail.

        You will be directed to your dashboard in Aperta, where you will see your invitation. Selecting "yes" confirms your assignment as Academic Editor. Selecting "yes" to accept this assignment will allow you to access the full submission from the Dashboard link in your main menu.

      TEXT
      template % template_data
    end
    # rubocop:enable Metrics/LineLength, Metrics/MethodLength

    def add_invitee_as_academic_editor_on_paper!(invitation)
      invitee = User.find(invitation.invitee_id)
      paper.add_academic_editor(invitee)
    end

    def template_data
      {
        manuscript_title: paper.display_title(sanitized: false),
        journal_name: paper.journal.name,
        author_name: paper.creator.full_name,
        authors: AuthorsList.authors_list(paper),
        abstract: abstract,
        dashboard_url: client_dashboard_url
      }
    end

    def abstract
      return 'Abstract is not available' unless paper.abstract
      paper.abstract
    end
  end
end
