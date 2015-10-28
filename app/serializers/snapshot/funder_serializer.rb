class Snapshot::FunderSerializer < Snapshot::BaseSerializer
  def initialize(funder)
    @funder = funder
  end

  def as_json
    { name: "funder", type: "properties", children: snapshot_funder }
  end

  def snapshot_funder
    snapshot_properties + snapshot_nested_questions
  end

  def snapshot_properties
    properties = []
    properties << snapshot_property("name", "text", @funder.name)
    properties << snapshot_property("grant_number", "text", @funder.grant_number)
    properties << snapshot_property("website", "text", @funder.website)
  end

  def snapshot_nested_questions
    nested_questions = TahiStandardTasks::Funder.nested_questions.where(parent_id: nil).order('position')
    nested_questions.map do |question|
      Snapshot::NestedQuestionSerializer.new(question, @funder).as_json
    end
  end
end
