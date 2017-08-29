require 'rails_helper'

describe do
  subject(:serializer) { CardContentSerializer.new(card_content) }
  let(:card_content) do
    FactoryGirl.create(:card_content,
                       allow_annotations: true,
                       allow_file_captions: true,
                       allow_multiple_uploads: true,
                       content_type: "radio",
                       editor_style: "basic",
                       condition: "isEditable",
                       ident: "ident",
                       instruction_text: "instruction",
                       label: "label",
                       possible_values: ["possible"],
                       text: "text",
                       value_type: "boolean",
                       error_message: "error",
                       visible_with_parent_answer: true)
  end

  describe '#as_json' do
    let(:json) { serializer.as_json }

    it 'serializes attributes' do
      aggregate_failures('json') do
        card_content_json = json[:card_content]
        expect(card_content_json).to include(id: card_content.id)
        expect(card_content_json).to include(allow_annotations: card_content.allow_annotations)
        expect(card_content_json).to include(allow_file_captions: card_content.allow_file_captions)
        expect(card_content_json).to include(allow_multiple_uploads: card_content.allow_multiple_uploads)
        expect(card_content_json).to include(content_type: card_content.content_type)
        expect(card_content_json).to include(editor_style: card_content.editor_style)
        expect(card_content_json).to include(condition: card_content.condition)
        expect(card_content_json).to include(ident: card_content.ident)
        expect(card_content_json).to include(instruction_text: card_content.instruction_text)
        expect(card_content_json).to include(label: card_content.label)
        expect(card_content_json).to include(possible_values: card_content.possible_values)
        expect(card_content_json).to include(text: card_content.text)
        expect(card_content_json).to include(value_type: card_content.value_type)
        expect(card_content_json).to include(visible_with_parent_answer: card_content.visible_with_parent_answer)
        expect(card_content_json).to include(error_message: card_content.error_message)
      end
    end
  end
end
