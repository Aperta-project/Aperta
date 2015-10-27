require "rails_helper"

describe Snapshot::PublishingRelatedQuestionsTaskSerializer do
  let(:publishing_related_questions_task) {FactoryGirl.create(:publishing_related_questions_task)}

  it "serializes a publishing related questions task" do
    snapshot = Snapshot::PublishingRelatedQuestionsTaskSerializer.new(publishing_related_questions_task).as_json

    expect(snapshot[0][:name]).to eq("published_elsewhere")
    expect(snapshot[0][:children][0][:name]).to eq("taken_from_manuscripts")
    expect(snapshot[0][:children][1][:name]).to eq("upload_related_work")
    expect(snapshot[1][:name]).to eq("submitted_in_conjunction")
    expect(snapshot[1][:children][0][:name]).to eq("corresponding_title")
    expect(snapshot[1][:children][1][:name]).to eq("corresponding_author")
    expect(snapshot[2][:name]).to eq("previous_interactions_with_this_manuscript")
    expect(snapshot[2][:children][0][:name]).to eq("submission_details")
    expect(snapshot[3][:name]).to eq("presubmission_inquiry")
    expect(snapshot[3][:children][0][:name]).to eq("submission_details")
    expect(snapshot[4][:name]).to eq("other_journal_submission")
    expect(snapshot[4][:children][0][:name]).to eq("submission_details")
    expect(snapshot[5][:name]).to eq("author_was_previous_journal_editor")
    expect(snapshot[6][:name]).to eq("intended_collection")
    expect(snapshot[7][:name]).to eq("us_government_employees")
  end
end
