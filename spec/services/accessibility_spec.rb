require 'rails_helper'

describe Accessibility do

  describe "error conditions" do
    before { class FakeResource; end }
    after  { Object.send(:remove_const, :FakeResource) }

    context "without a matching policy" do
      it "will error" do
        expect { Accessibility.new(FakeResource.new).users }.to raise_error(ApplicationPolicy::ApplicationPolicyNotFound)
      end
    end

    context "without connected_users" do
      before do
        class FakeResourcesPolicy < ApplicationPolicy
          primary_resource :fake_resource
        end
      end
      after  { Object.send(:remove_const, :FakeResourcesPolicy) }

      it "will error" do
        expect { Accessibility.new(FakeResource.new).users }.to raise_error(NoMethodError, /connected_users/)
      end
    end
  end

  describe "#users" do
    let!(:users) { FactoryGirl.create_list(:user, 2) }

    before do
      class FakeResource; end

      class FakeResourcesPolicy < ApplicationPolicy
        primary_resource :fake_resource

        def connected_users
          User.all
        end

        def teleport?
          current_user == User.last
        end
      end
    end

    after do
      Object.send(:remove_const, :FakeResource)
      Object.send(:remove_const, :FakeResourcesPolicy)
    end

    context "with action specified" do
      it "will filter connected users using policy action" do
        expect(Accessibility.new(FakeResource.new, :teleport).users).to eq([User.last])
      end
    end

    context "without an action specified" do
      it "will return all connected users" do
        expect(Accessibility.new(FakeResource.new, nil).users).to match_array(users)
      end
    end
  end

end
