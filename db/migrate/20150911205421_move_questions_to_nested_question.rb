class MoveQuestionsToNestedQuestion < ActiveRecord::Migration
  def up
    Question.where(ident: "competing_interest") do |competing_interest|

      nested_competing_interest_question = NestedQuestion.new owner_id: competing_interest.owner_id,
        owner_type: competing_interest.owner_type,
        value: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://www.plosbiology.org/static/policies#competing'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
        value_type: "boolean",
        ident: "competing_interest"
      nested_competing_interest_question.save!

      nested_competing_interest_answer = NestedQuestionAnswer.new nested_question_id: nested_competing_interest_question.id,
        value_type: "boolean",
        owner_id: competing_interest.owner_id,
        owner_type: competing_interest.owner_type
      if competing_interest.answer == "Yes"
        nested_competing_interest_answer.value = "t"
      else
        nested_competing_interest_answer.answer = "f"
      end
      nested_competing_interest_answer.save!

      competing_statement = Question.where(ident: "competing_interest.competing_interest", owner_id: competing_interest.owner_id).first
      nested_competing_statement_question = NestedQuestion.new owner_id: competing_statement.owner_id,
        owner_type: competing_statement.owner_type,
        value: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
        value_type: "text",
        ident: "statement",
        parent_id: nested_competing_interest_question.id
      nested_competing_statement_question.save!

      nested_competing_statement_answer = NestedQuestionAnswer.new nested_question_id: nested_competing_statement_answer.id,
        value_type: "text",
        owner_id: competing_interest.owner_id,
        owner_type: competing_interest.owner_type
      if competing_interest
        nested_competing_statement_answer.value = competing_interest.answer
      end
      nested_competing_statement_answer.save!

    end
  end

  def down
    NestedQuestion.where(ident: "competing_interest") do |nested_competing_interest|
      competing_interest = Question.new ident: "competing_interest",
        owner_id: nested_competing_interest.owner_id,
        owner_type: nested_competing_interest.owner_type,
        task_id: nested_competing_interest.owner_id
      nested_competing_answer = NestedQuestionAnswer.where(nested_question_id: nested_competing_interest.id)
      if nested_competing_answer.value
        competing_interest.answer = "Yes"
      else
        competing_interest.answer = "No"
      end
      competing_interest.save!

      if nested_competing_answer.value
        nested_competing_statement_question = NestedQuestion.where(ident: "statement", parent_id: c.id).first
        nested_competing_statement_answer = NestedQuestionAnswer.where(nested_question_id: nested_competing_statement_question.id).first
        statement = Question.new ident: "competing_interest.competing_interest",
          owner_id: nested_competing_statement_question.owner_id,
          owner_type: nested_competing_statement_question.owner_type,
          task_id: nested_competing_statement_question.owner_id,
          answer: nested_competing_statement_answer.value
        statement.save!
      end
    end
  end

  # desc "migrate competing interests to nested questions cleanup"
  # task :migrate_competing_interests_to_cleanup => :environment do
  #   Question.where(ident: "competing_interest") do |competing_interest|
  #     Question.where(ident: "competing_interest.competing_interest", owner_id: competing_interest.owner_id).destroy_all
  #     competing_interest.destroy
  #   end
  # end

  # desc "migrate competing interests from nested questions cleanup"
  # task :migrate_competing_interests_from => :environment do
  #     destroy_nested_question nested_competing_interest.id
  #   NestedQuestion.where(ident: "competing_interest") do |nested_competing_interest|
  #   end
  #
  #   def destroy_children nested_question_id
  #     NestedQuestion.where(parent_id: nested_question_id) do |nested_question|
  #       destory_children nested_question.id
  #     end
  #
  #     NestedQuestionAnswer.where(nested_question_id: nested_question_id).destory_all
  #     NestedQuestion.where(id: nested_question_id).destroy_all
  #   end
  # end
end
