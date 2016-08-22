class Snapshot::PaperSerializer < Snapshot::BaseSerializer
  alias_method :paper, :model

  private

  def snapshot_properties
    versioned_text = paper.versioned_texts.order('id desc').first
    properties = [
      snapshot_property('abstract', 'text', paper.abstract),
      snapshot_property('accepted_at', 'datetime', paper.accepted_at.to_s),
      snapshot_property('doi', 'text', paper.doi),
      snapshot_property('first_submitted_at', 'datetime', paper.first_submitted_at.to_s),
      snapshot_property('journal_id', 'integer', paper.journal_id),
      snapshot_property('major_version', 'integer', versioned_text.major_version),
      snapshot_property('minor_version', 'integer', versioned_text.minor_version),
      snapshot_property('gradual_engagement', 'boolean', paper.gradual_engagement),
      snapshot_property('salesforce_manuscript_id', 'text', paper.salesforce_manuscript_id),
      snapshot_property('submitting_user_id', 'integer', versioned_text.submitting_user_id),
      snapshot_property('title', 'text', paper.title),
      snapshot_property('text', 'text', versioned_text.text),
      snapshot_property('original_text', 'text', versioned_text.original_text),
      Snapshot::AttachmentSerializer.new(paper.file).as_json
    ]
    properties
  end


end
