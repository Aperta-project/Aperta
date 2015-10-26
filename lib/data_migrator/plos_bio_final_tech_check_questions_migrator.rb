class DataMigrator::PlosBioFinalTechCheckQuestionsMigrator < DataMigrator::Base
  TASK_OWNER_TYPE = "PlosBioTechCheck::FinalTechCheckTask"

  IDENTS = {
    old: {
      OPEN_REJECTS_IDENT: "final_tech_check.open_rejects",
      HUMAN_SUBJECTS_IDENT: "final_tech_check.human_subjects",
      ETHICS_NEEDED_IDENT: "final_tech_check.ethics_needed",
      DATA_AVAILABLE_IDENT: "final_tech_check.data_available",
      SUPPORTING_INFORMATION_IDENT: "final_tech_check.supporting_information",
      DRYAD_URL_IDENT: "final_tech_check.dryad_url",
      FINANCIAL_DISCLOSURE_IDENT: "final_tech_check.financial_disclosure",
      TOBACCO_IDENT: "final_tech_check.tobacco",
      FIGURES_LEGIBLE_IDENT: "final_tech_check.figures_legible",
      CITED_IDENT: "final_tech_check.cited",
      COVER_LETTER_IDENT: "final_tech_check.cover_letter",
      BILLING_INQUIRIES_IDENT: "final_tech_check.billing_inquiries",
      ETHICS_STATEMENT_IDENT: "final_tech_check.ethics_statement"
    },

    new: {
      OPEN_REJECTS_IDENT: "open_rejects",
      HUMAN_SUBJECTS_IDENT: "human_subjects",
      ETHICS_NEEDED_IDENT: "ethics_needed",
      DATA_AVAILABLE_IDENT: "data_available",
      SUPPORTING_INFORMATION_IDENT: "supporting_information",
      DRYAD_URL_IDENT: "dryad_url",
      FINANCIAL_DISCLOSURE_IDENT: "financial_disclosure",
      TOBACCO_IDENT: "tobacco",
      FIGURES_LEGIBLE_IDENT: "figures_legible",
      CITED_IDENT: "cited",
      COVER_LETTER_IDENT: "cover_letter",
      BILLING_INQUIRIES_IDENT: "billing_inquiries",
      ETHICS_STATEMENT_IDENT: "ethics_statement"
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
    migrate_plos_bio_initial_tech_check_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: [TASK_OWNER_TYPE], owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    questions = []
    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "open_rejects",
      value_type: "boolean",
      text: "Check Section Headings of all new submissions (including Open Rejects). Should broadly follow: Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References, Acknowledgements, and Figure Legends.",
      additional_data: "Please ensure that all of the following sections are present and appear in your manuscript file in the following order: Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References, Acknowledgments, and Figure Legends. More detailed guidelines can be found on our website: http://journals.plos.org/plosbiology/s/submission-guidelines#loc-manuscript-organization.",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "human_subjects",
      value_type: "boolean",
      text: "Check the ethics statement - does it mention Human Participants? If so, flag this with the editor in the discussion below.",
      position: 2
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "ethics_needed",
      value_type: "boolean",
      text: "Check if there are any obvious ethical flags (mentions of animal/human work in the title/abstract), check that there's an ethics statement. If not, ask the authors about this.",
      position: 3
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "data_available",
      value_type: "boolean",
      text: "Is the data available? If not, or it's only available by contacting an author or the institution, make a note in the discussion below.",
      position: 4
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "supporting_information",
      value_type: "boolean",
      text: "If author indicates the data is available in Supporting Information, check to make sure there are Supporting Information files in the submission (don't need to check for specifics at this stage).",
      position: 5
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "dryad_url",
      value_type: "boolean",
      text: "If the author has mentioned Dryad in their Data statement, check that they've included the Dryad reviewer URL. If not, make a note in the discussion below.",
      position: 6
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "financial_disclosure",
      value_type: "boolean",
      text: "If Financial Disclosure Statement is not complete (they've written N/A or something similar), message author.",
      additional_data: "Please complete the Financial Disclosure Statement field of the online submission form.",
      position: 7
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "tobacco",
      value_type: "boolean",
      text: "If the Financial Disclosure Statement includes any companies from the Tobacco Industry, make a note in the discussion below.",
      additional_data: "This section should describe sources of funding that have supported the work. Please include relevant grant numbers and the URL of any funder's Web site.",
      position: 8
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "figures_legible",
      value_type: "boolean",
      text: "If any figures are completely illegible, contact the author.",
      additional_data: "Your Figure is not easily legible. Please provide a higher quality version of this Figure while ensuring the file size remains below 10MB. We recommend saving your figures as TIFF files using LZW compression. More detailed guidelines can be found on our website: http://journals.plos.org/plosbiology/s/figures.",
      position: 9
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "cited",
      value_type: "boolean",
      text: "If any files or figures are cited but not included in the submission, message the author.",
      additional_data: "Please note you have cited a file in your manuscript that has not been included with your submission. Please upload this file, or if this file was cited in error, please remove the corresponding citation from your manuscript.",
      position: 10
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "cover_letter",
      value_type: "boolean",
      text: "Have the authors asked any questions in the cover letter? If yes, contact the editor/journal team.",
      position: 11
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "billing_inquiries",
      value_type: "boolean",
      text: "Have the authors mentioned any billing information in the cover letter? If yes, contact the editor/journal team.",
      additional_data: "Please note that our policy requires the removal of any mention of billing information from the cover letter. I have forwarded your query to our Billing Team (authorbilling@plos.org). Further infromation about Publication Fees can be found here: http://www.plos.org/publications/publication-fees/. Thank you, PLOS Biology",
      position: 12
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "ethics_statement",
      value_type: "boolean",
      text: "If an Ethics Statement is present, make a note in the discussion below.",
      position: 13
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id: nil, owner_type: TASK_OWNER_TYPE, ident: q.ident).exists?
        q.save!
      end
    end
  end

  def migrate_plos_bio_initial_tech_check_questions
    IDENTS[:old].each_pair do |key, old_ident|
      new_ident = IDENTS[:new][key]
      old_questions = Question.where(ident: old_ident)
      migrating(count: old_questions.count, from: old_ident, to: new_ident) do
        old_questions.each do |old_question|
          if old_question.task.nil?
            puts
            puts
            puts "    #{yellow('Skipping')} because corresponding task does not exist for #{old_question.inspect}"
            puts
            @subtract_from_expected_count += 1
            next
          end

          nested_question = NestedQuestion.where(owner_type: TASK_OWNER_TYPE, owner_id: nil, ident: new_ident).first!

          case nested_question.value_type
          when "boolean"
            NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: (old_question.answer == "Yes" || old_question.answer.eql?(true) || old_quesiton.answer.downcase == "true"),
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
          else
            NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: old_question.answer,
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
          end

        end
      end
    end
  end

  def verify_counts
    verify_count(
      expected: Question.where("ident LIKE 'final_tech_check.%'").count - @subtract_from_expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: { owner_type: TASK_OWNER_TYPE, owner_id: nil }).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      fail "Count mismatch on NestedQuestionAnswer for #{TASK_OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
