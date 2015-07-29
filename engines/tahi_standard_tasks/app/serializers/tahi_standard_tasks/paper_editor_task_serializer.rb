module TahiStandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids
    has_one :editor, serializer: UserSerializer, include: true, root: :users
    has_one :invitation, include: true
    attributes :letter

    def editor
      object.paper.editor
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
