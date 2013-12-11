require 'spec_helper'

describe PaperAdminTask do
  describe "initialization" do
    describe "title" do
      it "initializes title to 'Paper Shepherd'" do
        expect(PaperAdminTask.new.title).to eq 'Paper Shepherd'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(PaperAdminTask.new(title: 'foo').title).to eq 'foo'
        end
      end
    end
  end
end
