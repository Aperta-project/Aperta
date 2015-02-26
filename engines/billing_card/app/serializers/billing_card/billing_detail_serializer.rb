module BillingCard
  class BillingDetailSerializer < ::ActiveModel::Serializer
    attributes :id,
      :pfa_funding_statement,
      :pfa_question_1,
      :pfa_question_1a,
      :pfa_question_1b,
      :pfa_question_2,
      :pfa_question_2a,
      :pfa_question_2b,
      :pfa_question_3,
      :pfa_question_3a,
      :pfa_question_4,
      :pfa_question_4a,
      :pfa_amount_to_pay,
      :pfa_supporting_docs,
      :pfa_additional_comments,
      :first_name,
      :last_name,
      :title,
      :department,
      :affiliation1,
      :affiliation2,
      :phone_number,
      :email_address,
      :address1,
      :address2,
      :city,
      :state,
      :postal_code,
      :country

    has_one :billing_card_task, embed: :id
  end
end
