require 'rails_helper'

describe SnapshotMigrator do
  let(:converter) { HtmlSanitizationSnapshotConverter.new }
  let(:title) { '<div>Some title</div><foo>Some foo</foo>' }
  let(:caption) { '<div>Some caption</div><foo>Some foo</foo>' }
  let(:dummy_question_attachment) { FactoryGirl.create(:question_attachment) }
  let(:contents) do
    { 'name' => 'question-attachment',
      'type' => 'properties',
      'children' =>
      [{ 'name' => 'id', 'type' => 'integer', 'value' => dummy_question_attachment.id.to_s },
       { 'name' => 'caption', 'type' => 'text', 'value' => caption },
       { 'name' => 'category', 'type' => 'text', 'value' => nil },
       { 'name' => 'file', 'type' => 'text', 'value' => 'PLOS+Biology+Cover+Letter.pdf' },
       { 'name' => 'file_hash',
         'type' => 'text',
         'value' => 'e04d1cd811ffbb2348403f5433a4a2013017a318cb038bd73d5d289ef0489a3b' },
       { 'name' => 'label', 'type' => 'text', 'value' => nil },
       { 'name' => 'publishable', 'type' => 'boolean', 'value' => nil },
       { 'name' => 'status', 'type' => 'text', 'value' => 'done' },
       { 'name' => 'title', 'type' => 'text', 'value' => title },
       { 'name' => 'url', 'type' => 'url', 'value' => '/resource_proxy/7DSbQpyFv8ALcdz55KgZpJx1' },
       { 'name' => 'owner_type', 'type' => 'text', 'value' => 'Answer' },
       { 'name' => 'owner_id', 'type' => 'integer', 'value' => 118_022 }] }
  end
  let!(:snapshot) { FactoryGirl.create(:snapshot, contents: contents) }

  describe '#call' do
    it 'migrates the keys in the Snapshot' do
      migrator = SnapshotMigrator.new('question-attachment', ['caption', 'title'], converter)
      migrator.call!

      snapshot.reload

      new_title = snapshot.contents['children'][8]['value']
      new_caption = snapshot.contents['children'][1]['value']

      expect(new_title).to eq '<div>Some title</div>Some foo'
      expect(new_caption).to eq '<div>Some caption</div>Some foo'
    end
  end
end
