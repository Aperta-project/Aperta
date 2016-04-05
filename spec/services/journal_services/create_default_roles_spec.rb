require 'rails_helper'

describe JournalServices::CreateDefaultRoles do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    allow_any_instance_of(Journal).to receive(:setup_defaults)
  end

  it "will create default old_roles" do
    old_roles = JournalServices::CreateDefaultRoles.call(journal)
    expect(old_roles.count).to eq(2)
  end

  it "will raise a service error if it fails" do
    allow(journal).to receive(:old_roles).and_raise(ActiveRecord::RecordInvalid.new(OldRole.new))
    expect do
      JournalServices::CreateDefaultRoles.call(journal)
    end.to raise_error(JournalServices::ServiceError)
  end
end
