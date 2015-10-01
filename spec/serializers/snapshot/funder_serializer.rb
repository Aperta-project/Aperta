require "rails_helper"

describe Snapshot::FunderSerializer do
  let(:funder) { FactoryGirl.create(:funder) }

  def find_property properties, name
    properties.select { |p| p[:name] == name }.first[:value]
  end

  it "snapshots a funder's properties" do
    snapshot = Snapshot::FunderSerializer.new(funder).snapshot
    properties = snapshot[:properties]

    expect(find_property(properties, "name")).to eq(funder.name)
    expect(find_property(properties, "grant_number")).to eq(funder.grant_number)
    expect(find_property(properties, "website")).to eq(funder.website)
  end

  it "snapshots a funder's nested questions" do
    infulence_answer = FactoryGirl.create(:nested_question_answer)
    infulence_answer.value = "f"
    infulence_answer.nested_question_id = funder.nested_questions.first.id
    infulence_answer.owner_type = "Funder"
    infulence_answer.owner_id = funder.id
    role_answer = FactoryGirl.create(:nested_question_answer)
    role_answer.value = "This describes the funder's role"
    role_answer.nested_question_id = funder.nested_questions.last.id
    role_answer.owner_type = "Funder"
    role_answer.owner_id = funder.id
    allow_any_instance_of(TahiStandardTasks::Funder).to receive(:nested_question_answers).and_return([role_answer, infulence_answer])

    snapshot = Snapshot::FunderSerializer.new(funder).snapshot

    expect(snapshot[:questions][0][:answers][0][:value]).to eq(infulence_answer.value)
    expect(snapshot[:questions][0][:children][0][:answers][0][:value]).to eq(role_answer.value)
  end
end
