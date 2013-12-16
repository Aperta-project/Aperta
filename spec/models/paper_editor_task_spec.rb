require 'spec_helper'

describe PaperEditorTask do
  describe "initialization" do
    describe "title" do
      it "initializes title to 'Assign Editor'" do
        expect(PaperEditorTask.new.title).to eq 'Assign Editor'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(PaperEditorTask.new(title: 'foo').title).to eq 'foo'
        end
      end
    end

    describe "role" do
      it "initializes title to 'admin'" do
        expect(PaperEditorTask.new.role).to eq 'admin'
      end

      context "when a role is provided" do
        it "uses the specified role" do
          expect(PaperEditorTask.new(role: 'foo').role).to eq 'foo'
        end
      end
    end
  end
end
