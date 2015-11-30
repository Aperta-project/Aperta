require 'rails_helper'

describe IhatJobRequest do
  describe '.recipe_name' do
    context "valid input/output formats" do
      it "finds a matching recipe" do
        expect(
          IhatJobRequest.recipe_name(from_format: "doc", to_format: "html")
        ).to eq("doc_to_html")
      end
    end

    context "invalid input/output formats" do
      it "throws an error" do
        expect {
          IhatJobRequest.recipe_name(from_format: "INVALID", to_format: "html")
        }.to raise_error(/unable to find/i)
      end
    end
  end
end
