class AuthorSerializer < ActiveModel::Serializer
  attributes :affiliation, :author_initial, :department,
             :email, :first_name, :id, :last_name, :middle_initial, :paper_id,
             :position, :secondary_affiliation, :title,
             :current_address_street,
             :current_address_street2,
             :current_address_city,
             :current_address_state,
             :current_address_country,
             :current_address_postal,
             :links,
             :owner_type_for_answer

  has_one :user, serializer: UserSerializer, embed: :ids, include: true

  has_many :nested_questions,
           serializer: NestedQuestionSerializer,
           embed: :ids,
           include: true
  has_many :nested_question_answers,
           serializer: NestedQuestionAnswerSerializer,
           embed: :ids,
           include: true

  def links
    {
      answers: answers_for_owner_path(owner_params),
      card: card_for_owner_path(owner_params)
    }
  end

  private

  def owner_params
    { owner_id: object.id, owner_type: object.class.name.underscore }
  end
end
