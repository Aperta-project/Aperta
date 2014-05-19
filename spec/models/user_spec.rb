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

    describe ".admins_for" do
      it "includes admins for the given journal" do
        journal = Journal.create!
        JournalRole.create! journal: journal, user: user2, admin: true
        editors = User.admins_for journal
        expect(editors).to include user2
        expect(editors).to_not include user1
      end
    end

    describe ".editors_for" do
      it "includes editors for the given journal" do
        journal = Journal.create!
        JournalRole.create! journal: journal, user: user2, editor: true
        editors = User.editors_for journal
        expect(editors).to include user2
        expect(editors).to_not include user1
      end
    end

    describe ".reviewers_for" do
      it "includes reviewers for the given journal" do
        journal = Journal.create!
        JournalRole.create! journal: journal, user: user2, reviewer: true
        reviewers = User.reviewers_for journal
        expect(reviewers).to include user2
        expect(reviewers).to_not include user1
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

      it "initializes with user_settings" do
        user = create :user
        expect(user.user_settings).to_not be_nil
      end
    end
  end

  describe ".new_with_session" do
    let(:personal_details) { {"personal_details" => {"given_names" => "Joe", "family_name" => "Smith"}} }
    let(:orcid_user) { {"devise.orcid" => {"info" => {"orcid_bio" => personal_details}}} }
    let(:orcid_data) { {"devise.orcid" => {"uid" => "myuid" } } }

    it "will prefill new user form with orcid info" do
      user = User.new_with_session(nil, orcid_user)
      expect(user.first_name).to eq('Joe')
      expect(user.last_name).to eq('Smith')
    end

    it "will set provider information" do
      user = User.new_with_session(nil, orcid_data)
      expect(user.provider).to eq('orcid')
      expect(user.uid).to eq('myuid')
    end
  end
end
