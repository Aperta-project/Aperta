class SurveySerializer < ActiveModel::Serializer
  attributes :id, :question, :answer
  has_one :declaration_task, embed: :id
end
