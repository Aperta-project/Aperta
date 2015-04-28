class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :ident, :question, :answer, :additional_data, :revision_number, :created_at, :updated_at
  has_one :question_attachment, embed: :id, include: true
  has_one :task, embed: :id, polymorphic: true
end
