require 'rails_helper'

describe GroupAuthor do
  subject(:group_author) { FactoryGirl.build(:group_author) }

  describe '#co_author_confirmed?' do
    it "returns true when co_author_state is 'confirmed'" do
      group_author.co_author_state = 'confirmed'
      expect(group_author.co_author_confirmed?).to eq(true)
    end
  end

  describe '#co_author_confirmed!' do
    it 'sets co_author_state to confirmed' do
      expect do
        group_author.co_author_confirmed!
      end.to change { group_author.co_author_state }.from(nil).to('confirmed')
    end

    it 'sets co_author_state_modified_at' do
      Timecop.freeze do |reference_time|
        expect do
          group_author.co_author_confirmed!
        end.to change { group_author.co_author_state_modified_at }.from(nil).to(reference_time)
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
