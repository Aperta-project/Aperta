# Light weight serializer used to do partial update of answers
# This was created initially to support validations, but it
# can be used for anything that requires more discrete
# changes to answer
class LightAnswerSerializer < ActiveModel::Serializer
  include ReadySerializable
  attributes :id
end
