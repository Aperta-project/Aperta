require 'spec_helper'

describe User do
  describe "scopes" do
    let! :admin do
      User.create! username: 'admin',
        first_name: 'Admin',
        last_name: 'Istrator',
        email: 'admin@example.org',
        password: 'password',
        password_confirmation: 'password',
        affiliation: 'PLOS',
        admin: true
    end

    let! :user do
      User.create! username: 'user',
        first_name: 'Us',
        last_name: 'Er',
        email: 'user@example.org',
        password: 'password',
        password_confirmation: 'password',
        affiliation: 'Research Institute'
    end

    describe ".admins" do
      it "includes admin users only" do
        admins = User.admins
        expect(admins).to include admin
        expect(admins).not_to include user
      end
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = User.new first_name: 'Mihaly', last_name: 'Csikszentmihalyi'
      expect(user.full_name).to eq 'Mihaly Csikszentmihalyi'
    end
  end
end
