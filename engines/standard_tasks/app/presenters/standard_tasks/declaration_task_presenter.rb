module StandardTasks
  class DeclarationTaskPresenter < TaskPresenter
    def data_attributes
      super.merge({
        'declarations' => task.paper.declarations.map { |d| d.slice(:question, :answer, :id) }
      })
    end
  end
end
