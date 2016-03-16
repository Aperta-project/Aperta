require 'rails_helper'

describe CommentLook do
  subject(:comment_look) { FactoryGirl.build(:comment_look) }

  context 'validation' do
    it 'is valid' do
      expect(comment_look.valid?).to be(true)
    end

    it 'requires a comment' do
      comment_look.comment = nil
      expect(comment_look.valid?).to be(false)
    end

    it 'requires a user' do
      comment_look.user = nil
      expect(comment_look.valid?).to be(false)
    end
  end
end
