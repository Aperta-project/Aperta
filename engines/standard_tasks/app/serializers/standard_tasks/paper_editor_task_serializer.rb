module StandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids

    has_many :possible_editors, serializer: UserSerializer, include: true, root: :users
    has_one :editor, serializer: UserSerializer, include: true, root: :users

    def possible_editors
      object.paper.possible_editors.includes(:affiliations)
    end

    def editor
      object.paper.editor
    end
  end
end
