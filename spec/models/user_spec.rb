require 'rails_helper'

describe User do
  it "will be valid with default factory data" do
    expect(build(:user)).to be_valid
  end

  describe "scopes" do
    describe ".starts_with" do
      it "return users which username, first_name or last_name begins with a value sent" do
        FactoryGirl.create(:user, username: 'lotus', first_name: 'Bradley', last_name: 'Ally')
        FactoryGirl.create(:user, username: 'calvin', first_name: 'Belle', last_name: 'Christen')
        FactoryGirl.create(:user, username: 'maximilian', first_name: 'Brody', last_name: 'Lexis')
        FactoryGirl.create(:user, username: 'beck', first_name: 'Indigo', last_name: 'James')

        results = User.starts_with('be').order("first_name")
        expect(results.count).to eq 2
        expect(results.first.first_name).to eq 'Belle'
        expect(results.last.first_name).to eq 'Indigo'
      end
    end

    describe ".admins" do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      it "includes admin users only" do
        user1.update! site_admin: true
        admins = User.site_admins
        expect(admins).to include user1
        expect(admins).not_to include user2
      end
    end
  end

  describe "#possible_flows" do
    it "returns all flows assigned to the user's roles" do
      role = FactoryGirl.create(:role)
      flow = FactoryGirl.create(:flow, role: role)
      user = FactoryGirl.create(:user)
      user.roles << role

      expect(user.possible_flows).to include(flow)
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = User.new first_name: 'Mihaly', last_name: 'Csikszentmihalyi'
      expect(user.full_name).to eq 'Mihaly Csikszentmihalyi'
    end
  end

  describe '#username' do
    it 'validates username' do
      user = FactoryGirl.build(:user, username: 'mihaly')
      expect(user.save!).to eq true
    end

    it 'validates against blank username' do
      user = FactoryGirl.build(:user, username: '')
      expect(user).to_not be_valid
      expect(user.errors.size).to eq 2
      expect(user.errors.to_a.first).to eq "Username can't be blank"
      expect(user.errors.to_a.last).to eq "Username is invalid"
    end

    it 'validates against username with dashes' do
      user = FactoryGirl.build(:user, username: 'blah-blah')
      expect(user).to_not be_valid
      expect(user.errors.size).to eq 1
      expect(user.errors.first).to eq [:username, "is invalid"]
    end
  end

  describe ".new_with_session" do
    let(:personal_details) { {"personal_details" => {"given_names" => "Joe", "family_name" => "Smith"}} }
    let(:orcid_session) do
      {"devise.provider" => {"orcid" => {"uid" => "myuid",
                                         "info" => {"orcid_bio" => personal_details}}}}
    end

    it "will prefill new user form with orcid info" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.first_name).to eq('Joe')
      expect(user.last_name).to eq('Smith')
    end

    it "will auto generate a password" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.password).not_to be_empty
    end
  end
end
