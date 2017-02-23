require 'rails_helper'

RSpec.describe Scratch, type: :model do

  describe 'writing and reading' do
    let(:scratch) do
      FactoryGirl.create(:scratch, contents: "42")
    end

    it "receives content and returns the same content" do
      expect(scratch.contents).to eq("42")
    end

    it "returns string values" do
      expect(scratch.contents.class).to eq(String)
    end
  end
end
