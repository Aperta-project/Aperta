require 'spec_helper'

describe PaperHelper do
  describe "#truncated_title" do
    context "when title isn't present" do
      it "returns short title" do
        paper = double(:paper, short_title: 'Hello world', title: nil)
        expect(helper.truncated_title(paper)).to eq('Hello world')
      end
    end

    context "when title is present" do
      it "returns title" do
        paper = double(:paper, short_title: 'Hello world', title: "Hello title world")
        expect(helper.truncated_title(paper)).to eq('Hello title world')
      end

      context "when title is longer than 110 characters" do
        it "returns truncated title" do
          title = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
          paper = double(:paper, short_title: 'Hello world', title: title)
          expect(helper.truncated_title(paper)).to eq('Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et...')
        end
      end
    end
  end
end
