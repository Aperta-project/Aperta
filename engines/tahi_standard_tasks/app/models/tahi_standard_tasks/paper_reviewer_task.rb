# coding: utf-8
module TahiStandardTasks
  class PaperReviewerTask < ::Task
    DEFAULT_TITLE = 'Invite Reviewers'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    include Invitable

    def invitation_invited(invitation)
      ReviewerMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      ReviewerReportTaskCreator.new(
        originating_task: self,
        assignee_id: invitation.invitee_id
      ).process
      ReviewerMailer.delay.reviewer_accepted(invitation_id: invitation.id)
    end

    def invitation_declined(invitation)
      ReviewerMailer.delay.reviewer_declined(invitation_id: invitation.id)
    end

    def invitation_rescinded(invitation)
      if invitation.invitee.present?
        invitation.invitee.resign_from!(assigned_to: invitation.task.journal,
                                        role: invitation.invitee_role)
      end
    end

    def active_invitation_queue
      paper.draft_decision.invitation_queue ||
        InvitationQueue.create(task: self, decision: paper.draft_decision)
    end

    def array_attributes
      super + [:reviewer_ids]
    end

    def self.permitted_attributes
      super + [{ reviewer_ids: [] }]
    end

    def update_responder
      TahiStandardTasks::UpdateResponders::PaperReviewerTask
    end

    def invitee_role
      Role::REVIEWER_ROLE
    end

    def invitation_template
      LetterTemplate.new(
        salutation: "Dear [REVIEWER NAME],",
        body: invitation_body_template
      )
    end

    private

    def invitation_body_template
      template = <<-TEXT.strip_heredoc
<p>You've been invited as a Reviewer on "{{ manuscript.title }}", for {{ journal.name }}.</p>
<p>The abstract is included below. We would ideally like to have reviews returned to us within {{ invitation.due_in_days | default 10}} days. If you require additional time, please do let us know so that we may plan accordingly.</p>
<p>Please only accept this invitation if you have no conflicts of interest. If in doubt, please feel free to contact us for advice. If you are unable to review this manuscript, we would appreciate suggestions of other potential reviewers.</p>
<p>We look forward to hearing from you.</p>
<p>Sincerely,</p>
<p>{{ journal.name }} Team</p>
<p>***************** CONFIDENTIAL *****************</p>
<p>{{ manuscript.paper_type }}</p>
<p>Manuscript Title:<br>
{{ manuscript.title }}</p>
<p>Authors:<br>
{% for author in manuscript.authors %}
{{ forloop.index }}. {{ author.last_name }}, {{ author.first_name }}<br>
{% endfor %}</p>
<p>Abstract:<br>
{{ manuscript.abstract | default 'Abstract is not available' }}</p>
TEXT
      # Note that this will become a LetterTemplate. When that
      # happens, the rendering part below simplifies to a call on the
      # LetterTemplate object.
      context = PaperReviewerScenario.new(self)
      Liquid::Template.parse(template).render(context)
    end
  end
end
