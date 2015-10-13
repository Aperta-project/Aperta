module PlosBioAcademicEditor
  class InviteAcademicEditorTaskSerializer < ::TaskSerializer
    embed :ids
    has_one :academic_editor, serializer: UserSerializer, include: true, root: :users
    has_one :invitation, include: true
    attributes :letter

    def academic_editor
      object.paper.academic_editor
    end

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
