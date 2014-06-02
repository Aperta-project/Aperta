require 'spec_helper'

describe "Role" do
  it "will be valid with default factory data" do
    expect(FactoryGirl.build(:role)).to be_valid
  end

  describe "#destroy" do
    it "will allow destroying a custom role" do
      role = FactoryGirl.create(:role, :custom)
      expect { role.destroy }.to change{ Role.count }.by(-1)
    end

    it "will not allow a required role to be destroyed" do
      role = FactoryGirl.create(:role, :admin)
      expect { role.destroy }.to_not change{ Role.count }
    end
  end
end
