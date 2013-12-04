require 'spec_helper'

describe ApplicationHelper do
  describe "#active_link_to" do
    context "when the current page is the link target" do
      it "includes an 'active' class" do
        allow(helper).to receive(:current_page?).and_return(true)
        output = helper.active_link_to "Dashboard", '/dashboard'
        expect(output).to eq '<a class="active" href="/dashboard">Dashboard</a>'
      end
    end

    context "when the current page is not the link target" do
      it "does not include an 'active' class" do
        allow(helper).to receive(:current_page?).and_return(false)
        output = helper.active_link_to "Dashboard", '/dashboard'
        expect(output).to eq '<a href="/dashboard">Dashboard</a>'
      end
    end
  end
end
