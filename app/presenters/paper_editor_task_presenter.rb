class PaperEditorTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'editors' => select_options_for_users(task.editors),
      'editor-id' => task.editor_id
    })
  end
end
