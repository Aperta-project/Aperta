require 'spec_helper'

describe JournalServices::CreateDefaultManuscriptManagerTemplates do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    allow_any_instance_of(Journal).to receive(:setup_defaults)
  end

  it "does what it says" do
    expect do
      JournalServices::CreateDefaultManuscriptManagerTemplates.call(journal)
    end.to change { journal.manuscript_manager_templates.count } .by(1)
  end
end
