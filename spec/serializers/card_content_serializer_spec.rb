# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
