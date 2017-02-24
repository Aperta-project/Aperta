# Serializer for authors that aren't individuals; they live in the
# same list as normal authors
class GroupAuthorSerializer < ActiveModel::Serializer
  attributes :initial,
             :contact_first_name,
             :contact_middle_name,
             :contact_last_name,
             :contact_email,
             :co_author_state,
             :co_author_state_modified_at,
             :co_author_state_modified_by_id,
             :position,
             :paper_id,
             :name,
             :id

  has_many :nested_questions,
           serializer: NestedQuestionSerializer,
           embed: :ids,
           include: true
  has_many :nested_question_answers,
           serializer: NestedQuestionAnswerSerializer,
           embed: :ids,
           include: true
end
