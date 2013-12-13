require 'spec_helper'

describe PaperEditorTask do
  describe "initialization" do
    describe "title" do
      it "initializes title to 'Assign Editor'" do
        expect(PaperEditorTask.new.title).to eq 'Assign Editor'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(PaperAdminTask.new(title: 'foo').title).to eq 'foo'
        end
      end
    end
  end
end
