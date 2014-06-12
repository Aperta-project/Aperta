class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :ident, :question, :answer, :additional_data
end
