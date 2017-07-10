require 'rails_helper'

describe TahiStandardTasks::ApexDelivery do
  describe "validating paper accepted" do
    it "the paper must be accepted when delivering to em" do
      delivery = FactoryGirl.build(:apex_delivery, destination: 'em')
      expect(delivery).to have(1).errors_on(:paper)
      delivery.paper.update(publishing_state: 'accepted')
      expect(delivery).to be_valid
    end

    it "the paper must be accepted when delivering to apex" do
      delivery = FactoryGirl.build(:apex_delivery, destination: 'apex')
      expect(delivery).to have(1).errors_on(:paper)
      delivery.paper.update(publishing_state: 'accepted')
      expect(delivery).to be_valid
    end

    it "the paper can be in any publishing_state when delivering to preprint" do
      delivery = FactoryGirl.build(:apex_delivery, destination: 'preprint')
      expect(delivery).to be_valid
    end
  end
end
