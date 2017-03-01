# Serializer for authors that aren't individuals; they live in the
# same list as normal authors
class GroupAuthorSerializer < ActiveModel::Serializer
  attributes :initial,
             :contact_first_name,
             :contact_middle_name,
             :contact_last_name,
             :contact_email,
             :position,
             :paper_id,
             :name,
             :id,
             :links,
             :owner_type_for_answer

  has_many :nested_questions,
           serializer: NestedQuestionSerializer,
           embed: :ids,
           include: true
  has_many :nested_question_answers,
           serializer: NestedQuestionAnswerSerializer,
           embed: :ids,
           include: true

  has_one :card, embed: :id

  def links
    {
      answers: answers_for_owner_path(owner_params)
    }
  end

  private

  def owner_params
    { owner_id: object.id, owner_type: object.class.name.underscore }
  end
end
