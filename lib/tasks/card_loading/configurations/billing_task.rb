# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class BillingTask
    def self.name
      "PlosBilling::BillingTask"
    end

    def self.title
      "Plos Billing Task"
    end

    def self.content
      [
        {
          ident: "plos_billing--first_name",
          value_type: "text",
          text: "First Name"
        },

        {
          ident: "plos_billing--last_name",
          value_type: "text",
          text: "Last Name"
        },

        {
          ident: "plos_billing--title",
          value_type: "text",
          text: "Title"
        },

        {
          ident: "plos_billing--department",
          value_type: "text",
          text: "Department"
        },

        {
          ident: "plos_billing--phone_number",
          value_type: "text",
          text: "Phone"
        },

        {
          ident: "plos_billing--email",
          value_type: "text",
          text: "Email"
        },

        {
          ident: "plos_billing--address1",
          value_type: "text",
          text: "Address Line 1"
        },

        {
          ident: "plos_billing--address2",
          value_type: "text",
          text: "Address Line 2 (optional)"
        },

        {
          ident: "plos_billing--city",
          value_type: "text",
          text: "City"
        },

        {
          ident: "plos_billing--state",
          value_type: "text",
          text: "State or Province"
        },

        {
          ident: "plos_billing--postal_code",
          value_type: "text",
          text: "ZIP or Postal Code"
        },

        {
          ident: "plos_billing--country",
          value_type: "text",
          text: "Country"
        },

        {
          ident: "plos_billing--affiliation1",
          value_type: "text",
          text: "Affiliation #1"
        },

        {
          ident: "plos_billing--affiliation2",
          value_type: "text",
          text: "Affiliation #2"
        },

        {
          ident: "plos_billing--payment_method",
          value_type: "text",
          text: "How would you like to pay?"
        },

        {
          ident: "plos_billing--pfa_question_1",
          value_type: "boolean",
          text: "Have you investigated if funding is available from your co-authors' institutions to pay the publication fee?"
        },

        {
          ident: "plos_billing--pfa_question_1a",
          value_type: "text",
          text: "If your co-authors' institutions will not provide any funding to publish the article, indicate why."
        },

        {
          ident: "plos_billing--pfa_question_1b",
          value_type: "text",
          text: "If your coauthors' institutions will provide partial funding to publish the article, indicate the amount they will pay towards your publication fee (in USD)."
        },

        {
          ident: "plos_billing--pfa_question_2",
          value_type: "boolean",
          text: "Have you investigated if funding is available from your institution to pay the publication fee?"
        },

        {
          ident: "plos_billing--pfa_question_2a",
          value_type: "text",
          text: "If your institution cannot provide any funding to publish the article, indicate why."
        },

        {
          ident: "plos_billing--pfa_question_2b",
          value_type: "text",
          text: "If your institution will provide partial funding to publish the article, indicate the amount it will pay toward your publication fee (in USD)."
        },

        {
          ident: "plos_billing--pfa_question_3",
          value_type: "boolean",
          text: "Do your co-authors have any other sources of funding that can be used towards the publication fee?"
        },

        {
          ident: "plos_billing--pfa_question_3a",
          value_type: "text",
          text: "Indicate the amount that they can pay (in USD)."
        },

        {
          ident: "plos_billing--pfa_question_4",
          value_type: "boolean",
          text: "Do you have any other sources of funding that can be used towards the publication fee?"
        },

        {
          ident: "plos_billing--pfa_question_4a",
          value_type: "text",
          text: "Indicate the amount that they can pay (in USD)."
        },

        {
          ident: "plos_billing--pfa_amount_to_pay",
          value_type: "text",
          text: "Given your answers to the above content on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
        },

        {
          ident: "plos_billing--pfa_supporting_docs",
          value_type: "boolean",
          text: "If you would like to provide documents to assist in demonstrating your request, you will have the opportunity to do so. After PLOS has received the completed application, the confirmation email will provide direction on where to send supplemental documents. Do you intend to supply supplemental documents?"
        },

        {
          ident: "plos_billing--pfa_amount_to_pay",
          value_type: "text",
          text: "Given your answers to the above content on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
        },

        {
          ident: "plos_billing--pfa_additional_comments",
          value_type: "text",
          text: "If you wish to make additional comments to support your request, provide them below. If you have no additional comments, enter \"None\" in the box."
        },

        {
          ident: "plos_billing--affirm_true_and_complete",
          value_type: "boolean",
          text: "You are acknowledging that you have read and agree to the following statement: I affirm that the information provided in this application is true and complete."
        },

        {
          ident: "plos_billing--agree_to_collections",
          value_type: "boolean",
          text: "I have read and agree to the Terms of Submission to PLOS Collections"
        },

        {
          ident: "plos_billing--gpi_country",
          value_type: "text",
          text: "Global Participation Initiative Country"
        },

        {
          ident: "plos_billing--ringgold_institution",
          value_type: "text",
          text: "Ringgold Institution"
        }
      ]
    end
  end
end
