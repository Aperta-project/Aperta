module StandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids

    has_many :editors, serializer: UserSerializer, include: true, root: :users
    has_one :editor, serializer: UserSerializer, include: true, root: :users

    def editors
      object.editors.includes(:affiliations)
    end
  end
end
