class DataMigrator::PlosBillingQuestionsMigrator < DataMigrator::Base
  BILLING_TASK_OWNER_TYPE = "PlosBilling::BillingTask"

  IDENTS = {
    old: {
      FIRST_NAME_IDENT: "plos_billing.first_name",
      LAST_NAME_IDENT: "plos_billing.last_name",
      TITLE_IDENT: "plos_billing.title",
      DEPARTMENT_IDENT: "plos_billing.department",
      PHONE_NUMBER_IDENT: "plos_billing.phone_number",
      EMAIL_IDENT: "plos_billing.email_address",
      ADDRESS1_IDENT: "plos_billing.address1",
      ADDRESS2_IDENT: "plos_billing.address2",
      CITY_IDENT: "plos_billing.city",
      STATE_IDENT: "plos_billing.state",
      POSTAL_CODE_IDENT: "plos_billing.postal_code",
      COUNTRY_IDENT: "plos_billing.country",
      AFFILIATION1_IDENT: "plos_billing.affiliation1",
      AFFILIATION2_IDENT: "plos_billing.affiliation2",
      PAYMENT_METHOD_IDENT: "plos_billing.payment_method",
      GPI_COUNTRY_IDENT: "plos_billing.gpi_country",
      RINGGOLD_INSTITUTION_IDENT: "plos_billing.selected_ringgold",
      PFA_QUESTION1_IDENT: "plos_billing.pfa_question_1",
      PFA_QUESTION1A_IDENT: "plos_billing.pfa_question_1a",
      PFA_QUESTION1B_IDENT: "plos_billing.pfa_question_1b",
      PFA_QUESTION2_IDENT: "plos_billing.pfa_question_2",
      PFA_QUESTION2A_IDENT: "plos_billing.pfa_question_2a",
      PFA_QUESTION2B_IDENT: "plos_billing.pfa_question_2b",
      PFA_QUESTION3_IDENT: "plos_billing.pfa_question_3",
      PFA_QUESTION3A_IDENT: "plos_billing.pfa_question_3a",
      PFA_QUESTION4_IDENT: "plos_billing.pfa_question_4",
      PFA_QUESTION4A_IDENT: "plos_billing.pfa_question_4a",
      PFA_AMOUNT_TO_PAY_IDENT: "plos_billing.pfa_amount_to_pay",
      PFA_SUPPORTING_DOCS_IDENT: "plos_billing.pfa_supporting_docs",
      ADDITIONAL_COMMENTS_IDENT: "plos_billing.pfa_additional_comments",
      AFFIRM_TRUE_AND_COMPLETE_IDENT: "plos_billing.affirm_true_and_complete",
      AGREE_TO_COLLECTIONS_IDENT: "plos_billing.agree_collections",
    },

    new: {
      FIRST_NAME_IDENT: "first_name",
      LAST_NAME_IDENT: "last_name",
      TITLE_IDENT: "title",
      DEPARTMENT_IDENT: "department",
      PHONE_NUMBER_IDENT: "phone_number",
      EMAIL_IDENT: "email",
      ADDRESS1_IDENT: "address1",
      ADDRESS2_IDENT: "address2",
      CITY_IDENT: "city",
      STATE_IDENT: "state",
      POSTAL_CODE_IDENT: "postal_code",
      COUNTRY_IDENT: "country",
      AFFILIATION1_IDENT: "affiliation1",
      AFFILIATION2_IDENT: "affiliation2",
      PAYMENT_METHOD_IDENT: "payment_method",
      GPI_COUNTRY_IDENT: "gpi_country",
      RINGGOLD_INSTITUTION_IDENT: "ringgold_institution",
      PFA_QUESTION1_IDENT: "pfa_question_1",
      PFA_QUESTION1A_IDENT: "pfa_question_1a",
      PFA_QUESTION1B_IDENT: "pfa_question_1b",
      PFA_QUESTION2_IDENT: "pfa_question_2",
      PFA_QUESTION2A_IDENT: "pfa_question_2a",
      PFA_QUESTION2B_IDENT: "pfa_question_2b",
      PFA_QUESTION3_IDENT: "pfa_question_3",
      PFA_QUESTION3A_IDENT: "pfa_question_3a",
      PFA_QUESTION4_IDENT: "pfa_question_4",
      PFA_QUESTION4A_IDENT: "pfa_question_4a",
      PFA_AMOUNT_TO_PAY_IDENT: "pfa_amount_to_pay",
      PFA_SUPPORTING_DOCS_IDENT: "pfa_supporting_docs",
      ADDITIONAL_COMMENTS_IDENT: "pfa_additional_comments",
      AFFIRM_TRUE_AND_COMPLETE_IDENT: "affirm_true_and_complete",
      AGREE_TO_COLLECTIONS_IDENT: "agree_to_collections"
    }
  }

  def initialize
    @subtract_from_expected_count = 0
  end

  def cleanup
    idents = IDENTS[:old].values
    puts
    puts yellow("Removing all Question(s) with idents: #{idents.join(', ')}")
    answer = ask "Are you sure you want to delete these Question(s)? [y/N]"
    loop do
      if answer =~ /n/i
        return
      elsif answer =~ /y/i
        break
      else
        answer = ask "Please answer y, n, or Ctrl-C to cancel."
      end
    end

    Question.where(ident: idents).destroy_all
  end

  def migrate!
    create_nested_questions
    migrate_billing_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: [BILLING_TASK_OWNER_TYPE], owner_id: nil },
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    questions = []

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "first_name",
      value_type: "text",
      text: "First Name"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "last_name",
      value_type: "text",
      text: "Last Name"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "title",
      value_type: "text",
      text: "Title"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "department",
      value_type: "text",
      text: "Department"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "phone_number",
      value_type: "text",
      text: "Phone"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "email",
      value_type: "text",
      text: "Email"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "address1",
      value_type: "text",
      text: "Address Line 1 (optional)"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "address2",
      value_type: "text",
      text: "Address Line 2 (optional)"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "city",
      value_type: "text",
      text: "City"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "state",
      value_type: "text",
      text: "State or Province"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "postal_code",
      value_type: "text",
      text: "ZIP or Postal Code"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "country",
      value_type: "text",
      text: "Country"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "affiliation1",
      value_type: "text",
      text: "Affiliation #1"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "affiliation2",
      value_type: "text",
      text: "Affiliation #2"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "payment_method",
      value_type: "text",
      text: "How would you like to pay?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_1",
      value_type: "boolean",
      text: "Have you investigated if funding is available from your co-authors' institutions to pay the publication fee?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_1a",
      value_type: "text",
      text: "If your co-authors' institutions will not provide any funding to publish the article, indicate why."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_1b",
      value_type: "text",
      text: "If your coauthors' institutions will provide partial funding to publish the article, indicate the amount they will pay towards your publication fee (in USD)."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_2",
      value_type: "boolean",
      text: "Have you investigated if funding is available from your institution to pay the publication fee?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_2a",
      value_type: "text",
      text: "If your institution cannot provide any funding to publish the article, indicate why."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_2b",
      value_type: "text",
      text: "If your institution will provide partial funding to publish the article, indicate the amount it will pay toward your publication fee (in USD)."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_3",
      value_type: "boolean",
      text: "Do your co-authors have any other sources of funding that can be used towards the publication fee?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_3a",
      value_type: "text",
      text: "Indicate the amount that they can pay (in USD)."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_4",
      value_type: "boolean",
      text: "Do you have any other sources of funding that can be used towards the publication fee?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_question_4a",
      value_type: "text",
      text: "Indicate the amount that they can pay (in USD)."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_amount_to_pay",
      value_type: "text",
      text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_supporting_docs",
      value_type: "text",
      text: "If you would like to provide documents to assist in demonstrating your request, you will have the opportunity to do so. After PLOS has received the completed application, the confirmation email will provide direction on where to send supplemental documents. Do you intend to supply supplemental documents?"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_amount_to_pay",
      value_type: "text",
      text: "Given your answers to the above questions on your funding availability, what is the amount that you and your co-authors can jointly pay for publication? (Specify in USD.)"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "pfa_additional_comments",
      value_type: "text",
      text: "If you wish to make additional comments to support your request, provide them below. If you have no additional comments, enter \"None\" in the box."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "affirm_true_and_complete",
      value_type: "boolean",
      text: "You are acknowledging that you have read and agree to the following statement: I affirm that the information provided in this application is true and complete."
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "agree_to_collections",
      value_type: "boolean",
      text: "I have read and agree to the Terms of Submission to PLOS Collections"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "gpi_country",
      value_type: "text",
      text: "Global Participation Initiative Country"
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: BILLING_TASK_OWNER_TYPE,
      ident: "ringgold_institution",
      value_type: "text",
      text: "Ringgold Institution"
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id: nil, owner_type: BILLING_TASK_OWNER_TYPE, ident: q.ident).exists?
        q.save!
      end
    end
  end

  def migrate_billing_questions
    IDENTS[:old].each_pair do |key, old_ident|
      new_ident = IDENTS[:new][key]
      old_questions =  Question.where(ident: old_ident)
      migrating(count: old_questions.count, from: old_ident, to: new_ident) do
        old_questions.each do |old_question|
          if old_question.task.nil?
            puts
            puts
            puts "    #{yellow("Skipping")} because corresponding task does not exist for #{old_question.inspect}"
            puts
            @subtract_from_expected_count += 1
            next
          end

          nested_question = NestedQuestion.where(owner_type: BILLING_TASK_OWNER_TYPE, owner_id: nil, ident: new_ident).first!

          if nested_question.value_type == "boolean"
            value = (old_question.answer == "Yes" || old_question.answer.eql?(true))
          else
            value = old_question.answer
          end

          NestedQuestionAnswer.create!(
            nested_question_id: nested_question.id,
            value_type: nested_question.value_type,
            owner_id: old_question.task.id,
            owner_type: old_question.task.class.base_class.sti_name,
            value: value,
            created_at: old_question.created_at,
            updated_at: old_question.updated_at
          )
        end
      end
    end
  end

  def verify_counts
    verify_count(
      expected: Question.where("ident LIKE 'plos_billing%'").count - @subtract_from_expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: {owner_type: BILLING_TASK_OWNER_TYPE, owner_id: nil}).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      raise "Count mismatch on NestedQuestionAnswer for #{BILLING_TASK_OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
