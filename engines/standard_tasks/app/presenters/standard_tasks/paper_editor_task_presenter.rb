module StandardTasks
  class PaperEditorTaskPresenter < TaskPresenter
    def data_attributes
      super.merge({
        'editors' => select_options_for_users(task.editors),
        'editorId' => task.editor_id
      })
    end
  end
end
