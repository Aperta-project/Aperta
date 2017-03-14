require "rails_helper"

describe "CardConfig::AnswerCreator" do

  let(:card_content) { FactoryGirl.create(:card_content) }
  let(:nested_question) { FactoryGirl.create(:old_nested_question) }

  let(:creator) { CardConfig::AnswerCreator.new(nested_question: nested_question, card_content: card_content) }

  context "NestedQuestion has no NestedQuestionAnswers" do
    it "does not create any answers" do
      expect { creator.call }.to_not change { Answer.count }
    end
  end

  context "NestedQuestion has a NestedQuestionAnswer" do
    let!(:nested_question_answer) do
      FactoryGirl.create(:old_nested_question_answer, :with_task_owner, :with_attachment, nested_question: nested_question)
    end

    let(:nested_question_attachment) do
      nested_question_answer.attachments.first
    end

    it "creates an Answer from the NestedQuestionAnswer" do
      answers = creator.call

      aggregate_failures("migrated attributes") do
        expect(answers.count).to eq(1)

        answer = answers.first
        expect(answer.owner).to eq(nested_question_answer.owner)
        expect(answer.paper).to eq(nested_question_answer.paper)
        expect(answer.value).to eq(nested_question_answer.value)
        expect(answer.additional_data).to eq(nested_question_answer.additional_data)
        expect(answer.created_at).to be_within_db_precision.of(nested_question_answer.created_at)
        expect(answer.updated_at).to be_within_db_precision.of(nested_question_answer.updated_at)
      end
    end

    it "copies any Attachments from the NestedQuestionAnswer to the Answer" do
      answers = creator.call
      attachments = answers.first.attachments

      aggregate_failures("migrated attachments") do
        expect(attachments.count).to eq(1)

        attachment = attachments.first
        expect(attachment[:file]).to eq(nested_question_attachment[:file])
      end
    end
  end

end
