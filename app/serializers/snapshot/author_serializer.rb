class Snapshot::AuthorSerializer < Snapshot::BaseSerializer
  def initialize(author)
    @author = author
  end

  def as_json
    { name: "author", type: "properties", children: snapshot_children }
  end

  private

  def snapshot_children
    snapshot_properties + snapshot_nested_questions
  end

  def snapshot_properties
    [
      snapshot_property("first_name", "text", @author.first_name),
      snapshot_property("last_name", "text", @author.last_name),
      snapshot_property("middle_initial", "text", @author.middle_initial),
      snapshot_property("position", "integer", @author.position),
      snapshot_property("email", "text", @author.email),
      snapshot_property("department", "text", @author.department),
      snapshot_property("title", "text", @author.title),
      snapshot_property("affiliation", "text", @author.affiliation),
      snapshot_property("secondary_affiliation", "text", @author.secondary_affiliation),
      snapshot_property("ringgold_id", "text", @author.ringgold_id),
      snapshot_property("secondary_ringgold_id", "text", @author.secondary_ringgold_id)
    ]
  end

  def snapshot_nested_questions
    nested_questions = @author.nested_questions.where(parent_id: nil).order('position')

    nested_questions.map do |question|
      Snapshot::NestedQuestionSerializer.new(question, @author).as_json
    end
  end
end
