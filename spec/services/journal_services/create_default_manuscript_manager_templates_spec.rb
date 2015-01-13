require 'rails_helper'

describe JournalServices::CreateDefaultManuscriptManagerTemplates do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    # prevent normal after create callback
    allow_any_instance_of(Journal).to receive(:setup_defaults)
    # make sure journal task types are created - required before MMT
    JournalServices::CreateDefaultTaskTypes.call(journal)
  end

  it "creates default manager templates" do
    expect do
      JournalServices::CreateDefaultManuscriptManagerTemplates.call(journal)
    end.to change { journal.manuscript_manager_templates.count } .by(1)
  end
end
