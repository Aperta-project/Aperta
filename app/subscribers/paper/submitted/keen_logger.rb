class Paper::Submitted::KeenLogger < KeenSubscriber

  def collection
    :papers
  end

  def payload
    {
      id: record.id,
      doi: record.doi,
      short_title: record.short_title,
      paper_type: record.paper_type,
      journal_id: record.journal_id,
      publishing_state: record.publishing_state,
      submitted_at: record.submitted_at,
      creator: record.creator.full_name,
      created_at: record.created_at,
      updated_at: record.updated_at
    }
  end

end
