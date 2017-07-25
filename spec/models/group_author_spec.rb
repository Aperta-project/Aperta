require 'rails_helper'

describe GroupAuthor do
  subject(:group_author) { FactoryGirl.create(:group_author) }
  subject(:staff_admin) { FactoryGirl.create(:user, :site_admin) }

  describe "validation" do
    it "will be valid with default factory data" do
      expect(group_author).to be_valid
    end

    describe 'email uniqueness' do
      let(:paper) { FactoryGirl.create(:paper) }

      it 'is unique among group authors on the paper' do
        group_author = FactoryGirl.create(:group_author, paper: paper)
        dupe_author = FactoryGirl.build(:group_author, paper: paper, email: group_author.email)
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end

      it 'is unique among authors on the paper' do
        author = FactoryGirl.create(:author, paper: paper)
        dupe_author = FactoryGirl.build(:group_author, paper: paper, email: author.email)
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end

      it 'is validated on email change' do
        group_author = FactoryGirl.create(:group_author, paper: paper)
        dupe_author = FactoryGirl.create(:group_author, paper: paper, email: "blah#{group_author.email}")
        expect(dupe_author).to be_valid
        dupe_author.email = group_author.email
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end
    end
  end

  describe '#co_author_confirmed?' do
    it "returns true when co_author_state is 'confirmed'" do
      group_author.update_coauthor_state('confirmed', staff_admin)
      expect(group_author.co_author_confirmed?).to eq(true)
    end
  end

  describe '#co_author_confirmed!' do
    it 'sets co_author_state to confirmed' do
      expect do
        group_author.co_author_confirmed!
      end.to change { group_author.co_author_state }.to('confirmed')
    end

    it 'sets co_author_state_modified_at' do
      Timecop.freeze do |reference_time|
        expect do
          group_author.co_author_confirmed!
        end.to change { group_author.co_author_state_modified_at }.to(reference_time)
      end
    end
  end

  describe 'callbacks' do
    context 'before_create' do
      describe '#set_default_co_author_state' do
        it "sets a default value of 'unconfirmed' on author creation" do
          expect(group_author.co_author_state).to eq 'unconfirmed'
        end
      end
    end
  end
end
