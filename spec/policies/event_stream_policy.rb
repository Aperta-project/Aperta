require 'rails_helper'

describe EventStreamPolicy do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:policy) { EventStreamPolicy.new(current_user: user, resource: paper) }

  describe "#show?" do
    it "calls show? on the resource's policy" do
      expect_any_instance_of(PapersPolicy).to receive(:show?)
      policy.show?
    end
  end
end

