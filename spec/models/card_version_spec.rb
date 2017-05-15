require 'rails_helper'

describe CardVersion do
  subject(:card_version) { FactoryGirl.create(:card_version) }

  context "#content_root" do
    it 'returns a root' do
      expect(card_version.content_root).to be
    end
  end

  context "create_default_answers" do
    let(:task) do
      FactoryGirl.create(:custom_card_task, card_version: card_version)
    end

    before do
      parent = card_version.content_root
      parent.children << [
        FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "foo", value_type: 'text', default_answer_value: 'hi'),
        FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "bar", value_type: 'boolean', default_answer_value: 'true'),
        FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "baz", value_type: 'boolean')
      ]
      card_version.create_default_answers(task)
    end

    it "creates an answer for each card content with a default_answer_value specified" do
      expect(Answer.count).to eq(2)
      expect(Answer.pluck(:value)).to contain_exactly("hi", "true")
    end

    it "assigns the task as the answer's owner" do
      expect(Answer.first.owner).to eq(task)
    end
  end
end
