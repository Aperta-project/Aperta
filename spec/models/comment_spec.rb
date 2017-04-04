require 'rails_helper'

describe Comment do
  subject(:comment) { FactoryGirl.build(:comment, body_html: '<b>Some comment</b>') }

  context 'validation' do
    it 'is valid' do
      expect(comment.valid?).to be(true)
    end

    it 'requires a body_html' do
      comment.body_html = nil
      expect(comment.valid?).to be(false)
    end

    it 'requires a task' do
      comment.task = nil
      expect(comment.valid?).to be(false)
    end
  end

  describe '#strip_body_html' do
    subject(:comment) { FactoryGirl.create(:comment, body_html: '<b>Some comment</b>') }
    it 'strips out html tags' do
      expect(comment.strip_body_html).to eq 'Some comment'
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
