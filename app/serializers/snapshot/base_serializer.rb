class Snapshot::BaseSerializer
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def as_json
    {
      name: model.class.name.demodulize.resourcerize,
      type: "properties",
      children: snapshot_children
    }
  end

  private

  def snapshot_children
    snapshot_properties + snapshot_nested_questions
  end

  def snapshot_nested_questions
    if model.respond_to?(:nested_questions)
      nested_questions = model.nested_questions.where(parent_id: nil).order('position')

      nested_questions.map do |question|
        Snapshot::NestedQuestionSerializer.new(question, model).as_json
      end
    else
      []
    end
  end

  def snapshot_properties
    []
  end

  def snapshot_property name, type, value
    { :name => name, :type => type, :value => value }
  end

end
