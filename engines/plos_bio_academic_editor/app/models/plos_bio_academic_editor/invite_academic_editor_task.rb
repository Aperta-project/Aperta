module PlosBioAcademicEditor
  class InviteAcademicEditorTask < Task
    register_task default_title: 'Invite Academic Editor', default_role: 'admin'

    include Invitable

    def invitation_invited(invitation)
      if paper.authors_list.present?
        invitation.update! information: "Here are the authors on the paper:\n\n#{paper.authors_list}"
      end
      ######
      AcademicEditorMailer.delay.notify_invited(
        invitation_id: invitation.id
      )
    end

    def invitation_accepted(invitation)
      replace_editor_and_follow_tasks invitation
      follow_reviewer_reports invitation
      follow_reviewer_recommendations invitation
      ####
      PaperAdminMailer.delay.notify_admin_of_editor_invite_accepted(
        paper_id:  invitation.paper.id,
        editor_id: invitation.invitee.id
      )
    end

    def invitee_role
      'academic_editor'
    end

    def invite_letter
      template = <<-TEXT.strip_heredoc
      Dear Dr. [ACADEMIC EDITOR NAME],

      I am writing to seek your advice as the academic editor on a manuscript entitled '%{manuscript_title}.'
      The corresponding author is %{author_first_name} %{author_last_name}, and the manuscript is under consideration at %{journal_name}.

      [ADD CUSTOMIZED TEXT HERE]

      We would be very grateful if you could let us know whether or not you are able to take on this assignment
      within 24 hours, so that we know whether to await your comments, or if we need to approach someone else.
      To accept or decline the assignment via our submission system, please use the link below. If you are
      available to help and have no conflicts of interest, you also can view the entire manuscript via this link.

      If you do take this assignment, and think that this work is not suitable for further consideration by %{journal_name}
      please tell us if it would be more appropriate for one of the other PLOS journals, and in particular,
      PLOS ONE (http://plos.io/1hPjumI). If you suggest PLOS ONE, please let us know if you would be willing
      to act as Academic Editor there. For more details on what this role would entail, please go to http://plos.io/1hm4mdg.

      I have appended further information, including a copy of the abstract and full list of authors below.

      My colleagues and I are grateful for your support and advice. Please don't hesitate to contact me should you
      have any questions.

      Kind regards,
      [YOUR NAME]

      TEXT

      template % template_date
    end

    private

    def template_date
      {
        manuscript_title: paper.title,
        author_first_name: paper.authors.first.first_name,
        author_last_name: paper.authors.first.last_name,
        journal_name: paper.journal.name,
        abstract: paper.abstract
      }
    end

    def replace_editor_and_follow_tasks(invitation)
      TaskRoleUpdater.new(task: self,
                          assignee_id: invitation.invitee_id,
                          paper_role_name: PaperRole::ACADEMIC_EDITOR).update
    end

    ### SHOULD AEs FOLLOW THESE TOO?
    def follow_reviewer_reports(invitation)
      paper.tasks.where(type: 'TahiStandardTasks::ReviewerReportTask').each do |task|
        ParticipationFactory.create(task: task, assignee: User.find(invitation.invitee_id))
      end
    end

    def follow_reviewer_recommendations(invitation)
      paper.tasks.where(type: 'TahiStandardTasks::ReviewerRecommendationsTask').each do |task|
        ParticipationFactory.create(task: task, assignee: User.find(invitation.invitee_id))
      end
    end
  end
end
