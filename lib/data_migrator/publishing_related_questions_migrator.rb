class DataMigrator::PublishingRelatedQuestionsMigrator < DataMigrator::Base
  TASK_OWNER_TYPE = "TahiStandardTasks::PublishingRelatedQuestionsTask"

  IDENTS = {
    old: {
      PUBLISHED_ELSEWHERE_IDENT: "publishing_related_questions.published_elsewhere",
      PUBLISHED_ELSEWHERE_TAKEN_FROM_MANUSCRIPTS_IDENT: "publishing_related_questions.published_elsewhere.taken_from_manuscripts",
      PUBLISHED_ELSEWHERE_UPLOAD_RELATED_WORK_IDENT: "publishing_related_questions.published_elsewhere.upload_related_work",
      SUBMITTED_IN_CONJUNCTION_IDENT: "publishing_related_questions.submitted_in_conjunction",
      SUBMITTED_IN_CONJUNCTION_CORRESPONDING_TITLE_IDENT: "publishing_related_questions.submitted_in_conjunction.corresponding_title",
      SUBMITTED_IN_CONJUNCTION_CORRESPONDING_AUTHOR_IDENT: "publishing_related_questions.submitted_in_conjunction.corresponding_author",
      PREVIOUS_INTERACTIONS_THIS_MANUSCRIPT_IDENT: "publishing_related_questions.previous_interactions.this_manuscript",
      PREVIOUS_INTERACTIONS_THIS_MANUSCRIPT_SUBMISSION_DETAILS_IDENT: "publishing_related_questions.previous_interactions.this_manuscript.submission_details",
      PREVIOUS_INTERACTIONS_PRESUBMISSION_INQUIRY_IDENT: "publishing_related_questions.previous_interactions.presubmission_inquiry",
      PREVIOUS_INTERACTIONS_PRESUBMISSION_INQUIRY_SUBMISSION_DETAILS_IDENT: "publishing_related_questions.previous_interactions.presubmission_inquiry.submission_details",
      PREVIOUS_INTERACTIONS_OTHER_JOURNAL_SUBMISSION_IDENT: "publishing_related_questions.previous_interactions.other_journal_submission",
      PREVIOUS_INTERACTIONS_OTHER_JOURNAL_SUBMISSION_SUBMISSION_DETAILS_IDENT: "publishing_related_questions.previous_interactions.other_journal_submission.submission_details",
      PREVIOUS_INTERACTIONS_JOURNAL_EDITOR_IDENT: "publishing_related_questions.previous_interactions.journal_editor",
      INTENDED_COLLECTION_IDENT: "publishing_related_questions.intended_collection",
      US_GOVERNMENT_EMPLOYEES_IDENT: "publishing_related_questions.us_government_employees"
    },

    new: {
      PUBLISHED_ELSEWHERE_IDENT: "published_elsewhere",
      PUBLISHED_ELSEWHERE_TAKEN_FROM_MANUSCRIPTS_IDENT: "taken_from_manuscripts",
      PUBLISHED_ELSEWHERE_UPLOAD_RELATED_WORK_IDENT: "upload_related_work",
      SUBMITTED_IN_CONJUNCTION_IDENT: "submitted_in_conjunction",
      SUBMITTED_IN_CONJUNCTION_CORRESPONDING_TITLE_IDENT: "corresponding_title",
      SUBMITTED_IN_CONJUNCTION_CORRESPONDING_AUTHOR_IDENT: "corresponding_author",
      PREVIOUS_INTERACTIONS_THIS_MANUSCRIPT_IDENT: "previous_interactions_with_this_manuscript",
      PREVIOUS_INTERACTIONS_THIS_MANUSCRIPT_SUBMISSION_DETAILS_IDENT: "submission_details",
      PREVIOUS_INTERACTIONS_PRESUBMISSION_INQUIRY_IDENT: "presubmission_inquiry",
      PREVIOUS_INTERACTIONS_PRESUBMISSION_INQUIRY_SUBMISSION_DETAILS_IDENT: "submission_details",
      PREVIOUS_INTERACTIONS_OTHER_JOURNAL_SUBMISSION_IDENT: "other_journal_submission",
      PREVIOUS_INTERACTIONS_OTHER_JOURNAL_SUBMISSION_SUBMISSION_DETAILS_IDENT: "submission_details",
      PREVIOUS_INTERACTIONS_JOURNAL_EDITOR_IDENT: "author_was_previous_journal_editor",
      INTENDED_COLLECTION_IDENT: "intended_collection",
      US_GOVERNMENT_EMPLOYEES_IDENT: "us_government_employees",
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
    migrate_publishing_related_questions
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
      ident: "published_elsewhere",
      value_type: "boolean",
      text: "Have the results, data, or figures in this manuscript been published elsewhere? Are they under consideration for publication elsewhere?",
      position: 1,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "taken_from_manuscripts",
          value_type: "text",
          text: "Please identify which results, data, or figures have been taken from other published or pending manuscripts, and explain why inclusion in this submission does not constitute dual publication.",
          position: 1
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "upload_related_work",
          value_type: "attachment",
          text: "Please also upload a copy of the related work with your submission as a 'Related Manuscript' item. Note that reviewers may be asked to comment on the overlap between the related submissions.",
          position: 2
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "submitted_in_conjunction",
      value_type: "boolean",
      text: "Is this manuscript being submitted in conjunction with another submission?",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "corresponding_title",
          value_type: "text",
          text: "Title",
          position: 1
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "corresponding_author",
          value_type: "text",
          text: "Corresponding author",
          position: 2
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "previous_interactions_with_this_manuscript",
      value_type: "boolean",
      text: "I have had previous interactions about this manuscript with a staff editor or Academic Editor of this journal.",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "submission_details",
          value_type: "text",
          text: "Please enter manuscript number and editor name, if known",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "presubmission_inquiry",
      value_type: "boolean",
      text: "I submitted a presubmission inquiry for this manuscript.",
      position: 4,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "submission_details",
          value_type: "text",
          text: "Please enter manuscript number and editor name, if known",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "other_journal_submission",
      value_type: "boolean",
      text: "This manuscript was previously submitted to a different PLOS journal as either a presubmission inquiry or a full submission.",
      position: 5,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "submission_details",
          value_type: "text",
          text: "Please enter manuscript number and editor name, if known",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "author_was_previous_journal_editor",
      value_type: "boolean",
      text: "One or more of the authors (including myself) currently serve, or have previously served, as an Academic Editor or Guest Editor for this journal.",
      position: 6
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "intended_collection",
      value_type: "text",
      text: "If your submission is intended for a PLOS Collection, enter the name of the collection in the box below. Please also ensure the name of the collection is included in your cover letter.",
      position: 7
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "us_government_employees",
      value_type: "boolean",
      text: "Are you or any of the contributing authors an employee of the United States Government?",
      position: 8
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id: nil, owner_type: TASK_OWNER_TYPE, ident: q.ident).exists?
        q.save!
      end
    end
  end

  def migrate_publishing_related_questions
    IDENTS[:old].each_pair do |key, old_ident|
      new_ident = IDENTS[:new][key]
      old_questions = Question.where(ident: old_ident)
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

          nested_question = NestedQuestion.where(owner_type: TASK_OWNER_TYPE, owner_id: nil, ident: new_ident).first!

          case nested_question.value_type
          when "boolean"
            NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: (old_question.answer == "Yes" || old_question.answer.eql?(true)),
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
          when "attachment"
            answer = NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: old_question.question_attachment[:attachment],
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
            answer.create_attachment!(old_question.question_attachment.attributes.except("id", "question_id", "question_type"))
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
      expected: Question.where("ident LIKE 'publishing_related_questions.%'").count - @subtract_from_expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: {owner_type: TASK_OWNER_TYPE, owner_id: nil}).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      raise "Count mismatch on NestedQuestionAnswer for #{TASK_OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
