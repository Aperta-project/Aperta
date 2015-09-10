class EditorAssigned::EventStoreLogger < EventStoreSubscriber

  def build_event
    paper = record.paper
    editors = paper.editors

    EventStore.new do |es|
      es.journal_id = paper.journal_id
      es.paper_id = paper.id
      es.data = {
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

end
