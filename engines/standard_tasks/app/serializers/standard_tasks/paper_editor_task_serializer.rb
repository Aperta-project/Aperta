module StandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids
    has_one :editor, serializer: UserSerializer, include: true, root: :users
    has_one :invitation, include: true

    def editor
      object.paper.editor
    end

    def invitation
      object.invitations.last
    end
  end
end
