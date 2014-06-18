class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :ident, :question, :answer, :additional_data, :task_id
end
