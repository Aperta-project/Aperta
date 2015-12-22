require 'rails_helper'

describe OldRole do
  it "will be valid with default factory data" do
    expect(FactoryGirl.build(:old_role)).to be_valid
  end

  describe "#destroy" do

    let(:journal) { FactoryGirl.create(:journal) }

    context "with an existing journal" do
      it "will allow destroying a custom old_role" do
        old_role = FactoryGirl.create(:old_role, :custom, journal: journal)
        expect { old_role.destroy }.to change{ OldRole.count }.by(-1)
      end

      it "will not allow a required old_role to be destroyed" do
        old_role = FactoryGirl.create(:old_role, :admin, journal: journal)
        expect { old_role.destroy }.to_not change{ OldRole.count }
      end
    end

    context "with a journal being destroyed" do
      before do
        journal.mark_for_destruction
      end

      it "will allow destroying a required old_role" do
        old_role = FactoryGirl.create(:old_role, :admin, journal: journal)
        expect { old_role.destroy }.to change{ OldRole.count }.by(-1)
      end
    end

    context "without a journal" do
      it "will allow destroying a required old_role" do
        old_role = FactoryGirl.create(:old_role, :admin, journal: nil)
        expect { old_role.destroy }.to change{ OldRole.count }.by(-1)
      end
    end
  end
end
