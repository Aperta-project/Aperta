#
# A snapshot serializer is responsible for serializing a given object/model
# into an acceptable format for storing snapshots (see `Snapshot` class).
#
# By default serializing happens in the following order:
#
#   * nested questions - Only serialized if the given object/model responds to \
#     `nested_questions`. Ignored otherwise.
#   * properties - Override in subclass to provide an array of specific \
#     properties.
#
# === Serializing nested_questions
#
# When the object/model being serialized it will try to recursively serialize
# any of its `nested_questions` and their associated answers. The default method
# used for doing this is `snapshot_nested_questions`. In most cases you will not
# need to override this.
#
# When the object/model doesn't respond to `nested_questions` this will not
# not attempt to serialize nested questions. It will simply ignore them and
# move on.
#
# === Serializing properties
#
# The internal method used is `snapshot_properties`. It returns an empty
# array by default and should be overriden in subclasses to provide serialized
# properties as needed.
#
# There is a `snapshot_property(name, type, value)` helper method available to
# subclasses that can be used for formatting serialized properties.
#
# === Additional Notes
#
# This class was going to be named `Snapshot::Serializer`, but there was a name
# conflict and `Serializer` was being resolved to another class. Thus the name
# `BaseSerializer` was born.
#
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
    snapshot_nested_questions +
      [snapshot_property("id", "integer", model.id)] +
      snapshot_properties
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

  def snapshot_property(name, type, value)
    { name: name, type: type, value: value }
  end

end
