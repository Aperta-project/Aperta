namespace 'nested-questions:seed' do
  task 'plos-billing-task': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--first_name",
      value_type: "text",
      text: "First Name",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--last_name",
      value_type: "text",
      text: "Last Name",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--title",
      value_type: "text",
      text: "Title",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--department",
      value_type: "text",
      text: "Department",
      position: 4
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--phone_number",
      value_type: "text",
      text: "Phone",
      position: 5
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--email",
      value_type: "text",
      text: "Email",
      position: 6
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--address1",
      value_type: "text",
      text: "Address Line 1",
      position: 7
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--address2",
      value_type: "text",
      text: "Address Line 2 (optional)",
      position: 8
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--city",
      value_type: "text",
      text: "City",
      position: 9
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--state",
      value_type: "text",
      text: "State or Province",
      position: 10
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--postal_code",
      value_type: "text",
      text: "ZIP or Postal Code",
      position: 11
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--country",
      value_type: "text",
      text: "Country",
      position: 12
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--affiliation1",
      value_type: "text",
      text: "Affiliation #1",
      position: 13
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--affiliation2",
      value_type: "text",
      text: "Affiliation #2",
      position: 14
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--payment_method",
      value_type: "text",
      text: "How would you like to pay?",
      position: 15
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_1",
      value_type: "boolean",
      text: "Have you investigated if funding is available from your co-authors' institutions to pay the publication fee?",
      position: 16
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_1a",
      value_type: "text",
      text: "If your co-authors' institutions will not provide any funding to publish the article, indicate why.",
      position: 17
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_1b",
      value_type: "text",
      text: "If your coauthors' institutions will provide partial funding to publish the article, indicate the amount they will pay towards your publication fee (in USD).",
      position: 18
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_2",
      value_type: "boolean",
      text: "Have you investigated if funding is available from your institution to pay the publication fee?",
      position: 19
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_2a",
      value_type: "text",
      text: "If your institution cannot provide any funding to publish the article, indicate why.",
      position: 20
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_2b",
      value_type: "text",
      text: "If your institution will provide partial funding to publish the article, indicate the amount it will pay toward your publication fee (in USD).",
      position: 21
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_3",
      value_type: "boolean",
      text: "Do your co-authors have any other sources of funding that can be used towards the publication fee?",
      position: 22
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_3a",
      value_type: "text",
      text: "Indicate the amount that they can pay (in USD).",
      position: 23
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_4",
      value_type: "boolean",
      text: "Do you have any other sources of funding that can be used towards the publication fee?",
      position: 24
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_question_4a",
      value_type: "text",
      text: "Indicate the amount that they can pay (in USD).",
      position: 25
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_amount_to_pay",
      value_type: "text",
      text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)",
      position: 26
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_supporting_docs",
      value_type: "boolean",
      text: "If you would like to provide documents to assist in demonstrating your request, you will have the opportunity to do so. After PLOS has received the completed application, the confirmation email will provide direction on where to send supplemental documents. Do you intend to supply supplemental documents?",
      position: 27
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_amount_to_pay",
      value_type: "text",
      text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)",
      position: 28
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--pfa_additional_comments",
      value_type: "text",
      text: "If you wish to make additional comments to support your request, provide them below. If you have no additional comments, enter \"None\" in the box.",
      position: 29
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--affirm_true_and_complete",
      value_type: "boolean",
      text: "You are acknowledging that you have read and agree to the following statement: I affirm that the information provided in this application is true and complete.",
      position: 30
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--agree_to_collections",
      value_type: "boolean",
      text: "I have read and agree to the Terms of Submission to PLOS Collections",
      position: 31
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--gpi_country",
      value_type: "text",
      text: "Global Participation Initiative Country",
      position: 32
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBilling::BillingTask.name,
      ident: "plos_billing--ringgold_institution",
      value_type: "text",
      text: "Ringgold Institution",
      position: 33
    }

    NestedQuestion.where(
      owner_type: PlosBilling::BillingTask.name
    ).update_all_exactly!(questions)
  end
end
