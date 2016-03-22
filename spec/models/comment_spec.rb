require 'rails_helper'

describe Comment do
  subject(:comment) { FactoryGirl.build(:comment) }

  context 'validation' do
    it 'is valid' do
      expect(comment.valid?).to be(true)
    end

    it 'requires a body' do
      comment.body = nil
      expect(comment.valid?).to be(false)
    end

    it 'requires a task' do
      comment.task = nil
      expect(comment.valid?).to be(false)
    end
  end

  describe '#created_by?' do
    let(:commenter) { FactoryGirl.build_stubbed(:user) }
    let(:other_commenter) { FactoryGirl.build_stubbed(:user) }

    it 'returns true when the given user is the commenter' do
      comment.commenter = commenter
      expect(comment.created_by?(commenter)).to be(true)
    end

    it 'returns false otherwise' do
      expect(comment.created_by?(other_commenter)).to be(false)
    end
  end
end
