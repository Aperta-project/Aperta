require 'rails_helper'

describe InstitutionalAccountsManager do
  let(:institution) do
    {
      id: "Hollywood Upstairs Medical College",
      text: "Hollywood Upstairs Medical College",
      nav_customer_number: 'C01234'
    }
  end
  let(:manager) { InstitutionalAccountsManager.new }
  let(:account_list) do
    ReferenceJson.find_or_create_by(name: "Institutional Account List")
  end

  describe "::ITEMS" do
    it "should have elements" do
      expect(InstitutionalAccountsManager::ITEMS.size).to_not eq 0
    end
  end

  describe "#seed!" do
    subject(:seed!) { manager.seed! }
    it "seeds" do
      expect { seed! }.to change { account_list.reload.items.size }
        .from(0).to(InstitutionalAccountsManager::ITEMS.size)
    end
  end

  describe "#add!" do
    subject(:add!) { manager.add!(**institution) }

    it "adds one institution" do
      expect { add! }.to change { account_list.reload.items.size }.by(1)
    end
  end

  describe "#remove!" do
    subject(:remove!) { manager.remove!(institution[:nav_customer_number]) }
    before { manager.add!(**institution) }

    it "removes one institution" do
      expect { remove! }.to change { account_list.reload.items.size }.by(-1)
    end
  end

  describe "#find" do
    subject(:find) { manager.find(institution[:nav_customer_number]) }
    before { manager.add!(**institution) }

    it "removes one institution" do
      expect(find).to eq institution.stringify_keys
    end
  end
end
