require 'rails_helper'

describe "Role" do
  it "will be valid with default factory data" do
    expect(FactoryGirl.build(:role)).to be_valid
  end

  describe "#destroy" do

    let(:journal) { FactoryGirl.create(:journal) }

    context "with an existing journal" do
      it "will allow destroying a custom role" do
        role = FactoryGirl.create(:role, :custom, journal: journal)
        expect { role.destroy }.to change{ Role.count }.by(-1)
      end

      it "will not allow a required role to be destroyed" do
        role = FactoryGirl.create(:role, :admin, journal: journal)
        expect { role.destroy }.to_not change{ Role.count }
      end
    end

    context "with a journal being destroyed" do
      before do
        journal.mark_for_destruction
      end

      it "will allow destroying a required role" do
        role = FactoryGirl.create(:role, :admin, journal: journal)
        expect { role.destroy }.to change{ Role.count }.by(-1)
      end
    end

    context "without a journal" do
      it "will allow destroying a required role" do
        role = FactoryGirl.create(:role, :admin, journal: nil)
        expect { role.destroy }.to change{ Role.count }.by(-1)
      end
    end
  end
end
