require 'spec_helper'

describe User do
  describe "scopes" do
    let! :user1 do
      User.create! username: 'admin',
        first_name: 'Admin',
        last_name: 'Istrator',
        email: 'admin@example.org',
        password: 'password',
        password_confirmation: 'password'
    end

    let! :user2 do
      User.create! username: 'user',
        first_name: 'Us',
        last_name: 'Er',
        email: 'user@example.org',
        password: 'password',
        password_confirmation: 'password'
    end

    describe ".admins" do
      it "includes admin users only" do
        user1.update! admin: true
        admins = User.admins
        expect(admins).to include user1
        expect(admins).not_to include user2
      end
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = User.new first_name: 'Mihaly', last_name: 'Csikszentmihalyi'
      expect(user.full_name).to eq 'Mihaly Csikszentmihalyi'
    end
  end

  describe "callbacks" do
    context "before_create" do

      it "initializes with a set of default flows" do
        user = FactoryGirl.create(:user)
        default_flow_titles = ["Up for grabs", "My tasks", "My papers", "Done"]
        expect(user.flows.map(&:title)).to match_array default_flow_titles
      end
    end
  end
end
