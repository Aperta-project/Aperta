require 'rails_helper'

describe JournalServices::CreateDefaultRoles do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    allow_any_instance_of(Journal).to receive(:setup_defaults)
  end

  it "will create default roles" do
    roles = JournalServices::CreateDefaultRoles.call(journal)
    expect(roles.count).to eq(3)
  end

  it "will raise a service error if it fails" do
    allow(journal).to receive(:roles).and_raise(ActiveRecord::RecordInvalid.new(Role.new))
    expect do
      JournalServices::CreateDefaultRoles.call(journal)
    end.to raise_error(JournalServices::ServiceError)
  end
end
