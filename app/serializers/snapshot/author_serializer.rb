class Snapshot::AuthorSerializer < Snapshot::BaseSerializer
  def initialize(author)
    @author = author
  end

  def as_json
    snapshot_properties + snapshot_nested_questions
  end

  def snapshot_properties
    properties = []
    properties << snapshot_property("first_name", "text", @author.first_name)
    properties << snapshot_property("last_name", "text", @author.last_name)
    properties << snapshot_property("middle_initial", "text", @author.middle_initial)
    properties << snapshot_property("position", "integer", @author.position)
    properties << snapshot_property("email", "text", @author.email)
    properties << snapshot_property("department", "text", @author.department)
    properties << snapshot_property("title", "text", @author.title)
    properties << snapshot_property("affiliation", "text", @author.affiliation)
    properties << snapshot_property("secondary_affiliation", "text", @author.secondary_affiliation)
    properties << snapshot_property("ringgold_id", "text", @author.ringgold_id)
    properties << snapshot_property("secondary_ringgold_id", "text", @author.secondary_ringgold_id)
  end

  def snapshot_nested_questions
    author_snapshot = []
    nested_questions = @author.nested_questions.where(parent_id: nil).order('id')

    nested_questions.each do |question|
      question_serializer = Snapshot::NestedQuestionSerializer.new question, @author
      author_snapshot << question_serializer.snapshot
    end

    author_snapshot
  end
end
