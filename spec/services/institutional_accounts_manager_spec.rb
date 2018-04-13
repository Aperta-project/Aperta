# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

    it "seeds some initial institutions" do
      expect { seed! }.to change { account_list.reload.items.size }
        .from(0).to(InstitutionalAccountsManager::ITEMS.size)
    end

    it "adds the institutions in alphabetical order" do
      seed!
      sorted = account_list.items.sort_by! { |i| i["text"] }
      expect(account_list.items).to eq sorted
    end
  end

  describe "#add!" do
    subject(:add!) { manager.add!(**institution) }
    before { manager.seed! }

    it "adds one institution" do
      expect { add! }.to change { account_list.reload.items.size }.by(1)
    end

    it "keeps the institution list in alphabetical order" do
      add!
      sorted = account_list.items.sort_by! { |i| i["text"] }
      expect(account_list.items).to eq sorted
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
