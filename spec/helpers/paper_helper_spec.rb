require 'spec_helper'

describe PaperHelper do
  describe "#truncated_title" do
    let(:paper) { double(:paper, display_title: title) }

    context "when display_title is shorter than 110 characters" do
      let(:title) { "Hello title world" }
      it "returns display_title" do
        expect(helper.truncated_title(paper)).to eq('Hello title world')
      end
    end

    context "when display_title is longer than 110 characters" do
      let(:title) do
        "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
      end

      it "returns truncated display_title" do
        expect(helper.truncated_title(paper)).to eq('Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et...')
      end
    end
  end
end
