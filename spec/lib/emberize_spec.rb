require 'rails_helper'

describe 'Emberize' do
  describe '.class_name' do
    it 'single table inheritance class names' do
      expect(Emberize.class_name(AdhocAttachment)).to eq('adhocAttachment')
    end

    it 'multi-word class names' do
      expect(Emberize.class_name(DiscussionTopic)).to eq('discussionTopic')
    end

    it 'single word class name' do
      expect(Emberize.class_name(Paper)).to eq('paper')
    end
  end
end
