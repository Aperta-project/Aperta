require "rails_helper"

describe Snapshot::ReviewerRecommendationsTaskSerializer do
  let(:task) { FactoryGirl.create(:reviewer_recommendation_task) }

  describe "serializes reviewer recommendations" do

    def find_property properties, name
      properties.select { |p| p[:name] == name }.first[:value]
    end

    it "serializes properties" do
      recommendation = FactoryGirl.create(:reviewer_recommendation)
      task.reviewer_recommendations << recommendation

      snapshot = Snapshot::ReviewerRecommendationsTaskSerializer.new(task).snapshot

      properties = snapshot[:recommendations][0][:recommendation][:properties]
      expect(find_property(properties, "first_name")).to eq(recommendation.first_name)
      expect(find_property(properties, "last_name")).to eq(recommendation.last_name)
      expect(find_property(properties, "middle_initial")).to eq(recommendation.middle_initial)
      expect(find_property(properties, "email")).to eq(recommendation.email)
      expect(find_property(properties, "department")).to eq(recommendation.department)
      expect(find_property(properties, "title")).to eq(recommendation.title)
      expect(find_property(properties, "affiliation")).to eq(recommendation.affiliation)
      expect(find_property(properties, "ringgold_id")).to eq(recommendation.ringgold_id)
    end

    it "serializes multiple recommendations" do
      recommendation1 = FactoryGirl.create(:reviewer_recommendation)
      recommendation2 = FactoryGirl.create(:reviewer_recommendation)
      task.reviewer_recommendations << recommendation1
      task.reviewer_recommendations << recommendation2

      snapshot = Snapshot::ReviewerRecommendationsTaskSerializer.new(task).snapshot

      properties = snapshot[:recommendations][0][:recommendation][:properties]
      expect(find_property(properties, "first_name")).to eq(recommendation1.first_name)
      expect(find_property(properties, "last_name")).to eq(recommendation1.last_name)
      expect(find_property(properties, "middle_initial")).to eq(recommendation1.middle_initial)
      expect(find_property(properties, "email")).to eq(recommendation1.email)
      expect(find_property(properties, "department")).to eq(recommendation1.department)
      expect(find_property(properties, "title")).to eq(recommendation1.title)
      expect(find_property(properties, "affiliation")).to eq(recommendation1.affiliation)
      expect(find_property(properties, "ringgold_id")).to eq(recommendation1.ringgold_id)
      properties = snapshot[:recommendations][1][:recommendation][:properties]
      expect(find_property(properties, "first_name")).to eq(recommendation2.first_name)
      expect(find_property(properties, "last_name")).to eq(recommendation2.last_name)
      expect(find_property(properties, "middle_initial")).to eq(recommendation2.middle_initial)
      expect(find_property(properties, "email")).to eq(recommendation2.email)
      expect(find_property(properties, "department")).to eq(recommendation2.department)
      expect(find_property(properties, "title")).to eq(recommendation2.title)
      expect(find_property(properties, "affiliation")).to eq(recommendation2.affiliation)
      expect(find_property(properties, "ringgold_id")).to eq(recommendation2.ringgold_id)
    end

    it "serializes nested questions" do
      recommendation = FactoryGirl.create(:reviewer_recommendation)
      task.reviewer_recommendations << recommendation
      recommending_answer = FactoryGirl.create(:nested_question_answer)
      recommending_answer.nested_question_id = recommendation.nested_questions.first.id
      recommending_answer.value = "recommend"
      reason_answer = FactoryGirl.create(:nested_question_answer)
      reason_answer.nested_question_id = recommendation.nested_questions.last.id
      reason_answer.value = "They're good people"
      allow_any_instance_of(TahiStandardTasks::ReviewerRecommendation).to receive(:nested_question_answers).and_return([recommending_answer, reason_answer])

      snapshot = Snapshot::ReviewerRecommendationsTaskSerializer.new(task).snapshot

      expect(snapshot[:recommendations][0][:recommendation][:questions][0][:answers][0][:value]).to eq("recommend")
      expect(snapshot[:recommendations][0][:recommendation][:questions][1][:answers][0][:value]).to eq("They're good people")
    end
  end
end
