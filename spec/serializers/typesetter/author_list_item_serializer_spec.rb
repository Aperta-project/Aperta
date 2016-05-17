require 'rails_helper'

describe Typesetter::AuthorListItemSerializer do
  subject(:serializer) { described_class.new(author_list_item) }
  let(:author_list_item) do
    FactoryGirl.build(:author_list_item, author: author)
  end
  let(:author) { FactoryGirl.build(:author) }
  let(:group_author) { FactoryGirl.build(:group_author) }

  let(:output) { serializer.serializable_hash }

  describe 'author' do
    it 'includes the author' do
      expect(output[:author]).to be
    end

    it <<-DESC.strip_heredoc do
      serializes the author by looking a serializer based on the author's
      type since it is polymorphic
    DESC
      author_list_item.author = Author.new
      expect(Typesetter::AuthorSerializer).to receive(:new)
        .with(author_list_item.author)
      serializer.serializable_hash

      author_list_item.author = GroupAuthor.new
      expect(Typesetter::GroupAuthorSerializer).to receive(:new)
        .with(author_list_item.author)
      serializer.serializable_hash
    end
  end
end
