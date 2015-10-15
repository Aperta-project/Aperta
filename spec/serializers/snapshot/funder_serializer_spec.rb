require "rails_helper"

describe Snapshot::FunderSerializer do
  let(:funder) { FactoryGirl.create(:funder) }

  def find_property properties, name
    properties.select { |p| p[:name] == name }.first
  end

  it "snapshots a funder's properties" do
    snapshot = Snapshot::FunderSerializer.new(funder).snapshot

    expect(find_property(snapshot, "name")[:value]).to eq(funder.name)
    expect(find_property(snapshot, "grant_number")[:value]).to eq(funder.grant_number)
    expect(find_property(snapshot, "website")[:value]).to eq(funder.website)
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

    funder_had_infulence = find_property(snapshot, "funder_had_influence")
    expect(funder_had_infulence[:value][:answer]).to eq(infulence_answer.value)

    funder_had_infulence_children = funder_had_infulence[:children]
    expect(find_property(funder_had_infulence_children, "funder_role_description")[:value][:answer]).to eq(role_answer.value)
  end
end
