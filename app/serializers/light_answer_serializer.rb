# Light weight serializer used to do partial update of answers
# This was created initially to support validations, but it
# can be used for anything that requires more discrete
# changes to answer
class LightAnswerSerializer < AuthzSerializer
  include ReadySerializable
  attributes :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
