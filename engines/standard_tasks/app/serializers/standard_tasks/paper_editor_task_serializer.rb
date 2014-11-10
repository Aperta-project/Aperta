module StandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids
    has_one :editor, serializer: UserSerializer, include: true, root: :users

    def editor
      object.paper.editor
    end
  end
end
