# Light weight serializer used to do partial update of answers
# This was created initially to support validations, but it
# can be used for anything that requires more discrete
# changes to answer
class LightAnswerSerializer < ActiveModel::Serializer
  include ReadySerializable
  attributes :id, :value

  # This is a workaround to the fact that we're stuck using
  # an older version of active_model_serializer
  # We only want to send down 'value' if we absolutely must do so
  # (in the case of rollbacks, for example)
  # so the user gets some idea on what's going on.
  # Once we update AMS, we should remove this method
  # and replace it with 'attribute :value, unless: :ready?'
  def attributes(*args)
    hash = super
    hash.delete(:value) if object.ready?
    hash
  end
end
