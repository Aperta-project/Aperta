module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author"

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "first_name",
        value_type: "text",
        text: "First Name"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "last_name",
        value_type: "text",
        text: "Last Name"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "title",
        value_type: "text",
        text: "Title"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "department",
        value_type: "text",
        text: "Department"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "phone_number",
        value_type: "text",
        text: "Phone"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "email",
        value_type: "text",
        text: "Email"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "address1",
        value_type: "text",
        text: "Address Line 1 (optional)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "address2",
        value_type: "text",
        text: "Address Line 2 (optional)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "city",
        value_type: "text",
        text: "City"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "state",
        value_type: "text",
        text: "State or Province"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "postal_code",
        value_type: "text",
        text: "ZIP or Postal Code"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "country",
        value_type: "text",
        text: "Country"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "affiliation1",
        value_type: "text",
        text: "Affiliation #1"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "affiliation2",
        value_type: "text",
        text: "Affiliation #2"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "payment_method",
        value_type: "text",
        text: "How would you like to pay?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_1",
        value_type: "boolean",
        text: "Have you investigated if funding is available from your co-authors' institutions to pay the publication fee?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_1a",
        value_type: "text",
        text: "If your co-authors' institutions will not provide any funding to publish the article, indicate why."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_1b",
        value_type: "text",
        text: "If your coauthors' institutions will provide partial funding to publish the article, indicate the amount they will pay towards your publication fee (in USD)."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_2",
        value_type: "boolean",
        text: "Have you investigated if funding is available from your institution to pay the publication fee?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_2a",
        value_type: "text",
        text: "If your institution cannot provide any funding to publish the article, indicate why."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_2b",
        value_type: "text",
        text: "If your institution will provide partial funding to publish the article, indicate the amount it will pay toward your publication fee (in USD)."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_3",
        value_type: "boolean",
        text: "Do your co-authors have any other sources of funding that can be used towards the publication fee?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_3a",
        value_type: "text",
        text: "Indicate the amount that they can pay (in USD)."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_4",
        value_type: "boolean",
        text: "Do you have any other sources of funding that can be used towards the publication fee?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_question_4a",
        value_type: "text",
        text: "Indicate the amount that they can pay (in USD)."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_amount_to_pay",
        value_type: "text",
        text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_supporting_docs",
        value_type: "text",
        text: "If you would like to provide documents to assist in demonstrating your request, you will have the opportunity to do so. After PLOS has received the completed application, the confirmation email will provide direction on where to send supplemental documents. Do you intend to supply supplemental documents?"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_amount_to_pay",
        value_type: "text",
        text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "pfa_additional_comments",
        value_type: "text",
        text: "If you wish to make additional comments to support your request, provide them below. If you have no additional comments, enter \"None\" in the box."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "affirm_true_and_complete",
        value_type: "boolean",
        text: "You are acknowledging that you have read and agree to the following statement: I affirm that the information provided in this application is true and complete."
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "agree_to_collections",
        value_type: "boolean",
        text: "I have read and agree to the Terms of Submission to PLOS Collections"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "gpi_country",
        value_type: "text",
        text: "Global Participation Initiative Country"
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "ringgold_institution",
        value_type: "text",
        text: "Ringgold Institution"
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def active_model_serializer
      TaskSerializer
    end
  end
end
