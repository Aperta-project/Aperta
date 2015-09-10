class EditorAssigned::KeenLogger < KeenSubscriber

  def collection
    :tasks
  end

  def payload
    editors = record.paper.editors

    {
      id: record.id,
      paper_id: record.paper.id,
      type: record.type,
      completed: record.completed,
      editor_count: editors.count,
      editors: editors.map do |editor|
          {
            id: editor.id,
            full_name: editor.full_name,
            username: editor.username
          }
      end
    }
  end

end
