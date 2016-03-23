module TahiStandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids
    has_many :academic_editors
    has_many :invitations, include: true
    attributes :invitation_template, :invitee_role

    def invitation
      object.invitations.last
    end

    def include_invitation?
      invitation && !invitation.accepted?
    end

    def letter
      object.invite_letter.to_json
    end
  end
end
