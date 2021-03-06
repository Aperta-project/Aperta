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

describe Snapshot::CardContentSerializer do
  subject(:serializer) { described_class.new(card_content, owner) }
  let(:card_content) do
    FactoryGirl.create(:card_content, ident: 'my-question', value_type: 'text', text: 'What up?')
  end
  let(:owner) { FactoryGirl.create(:ad_hoc_task) }

  describe '#as_json' do
    it 'serializes the card content without an answer' do
      expect(serializer.as_json).to eq(
        name: 'my-question',
        type: 'question',
        value: {
          id: card_content.id,
          title: 'What up?',
          answer_type: 'text',
          answer: nil,
          attachments: []
        },
        children: []
      )
    end

    context 'when it has repetitions' do
      let(:card_content) { FactoryGirl.create(:card_content, :unanswerable, ident: 'my-repeater', content_type: 'repeat') }
      let(:child) { FactoryGirl.create(:card_content, parent: card_content, ident: 'my-question', value_type: 'text', text: 'What up?') }
      let(:repetition) { FactoryGirl.create(:repetition, card_content: card_content, task: owner) }
      let!(:answer) { FactoryGirl.create(:answer, card_content: child, repetition: repetition, owner: owner, value: 'the sky') }

      it 'serializes the card content with each repetition and its answers' do
        expect(serializer.as_json).to eq(
          name: 'my-repeater',
          type: 'question',
          value: {
            id: card_content.id,
            title: nil,
            answer_type: nil,
            answer: nil,
            attachments: []
          },
          children: [
            name: 'my-question',
            type: 'question',
            value: {
              id: child.id,
              title: 'What up?',
              answer_type: 'text',
              answer: 'the sky',
              attachments: []
            },
            children: []
          ]
        )
      end
    end

    context 'when it has child content' do
      before do
        card_content.children << FactoryGirl.create(
          :card_content,
          ident: '1st_question',
          text: '1st level child question',
          children: [
            FactoryGirl.build(
              :card_content,
              ident: '2nd_question',
              text: '2nd level child question'
            )
          ]
        )
      end

      it 'serializes child content as nested questions' do
        expect(serializer.as_json).to eq(
          name: 'my-question',
          type: 'question',
          value: {
            id: card_content.id,
            title: 'What up?',
            answer_type: 'text',
            answer: nil,
            attachments: []
          },
          children: [{
            name: '1st_question',
            type: 'question',
            value: {
              id: card_content.children.first.id,
              title: '1st level child question', answer_type: 'text',
              answer: nil, attachments: []
            },
            children: [{
              name: '2nd_question',
              type: 'question',
              value: {
                id: card_content.children.first.children.first.id,
                title: '2nd level child question', answer_type: 'text',
                answer: nil, attachments: []
              },
              children: []
            }]
          }]
        )
      end
    end

    it 'serializes card content with an answer as nested questions' do
      FactoryGirl.create(
        :answer,
        owner: owner,
        value: 'Answer Value',
        card_content: card_content
      )

      expect(serializer.as_json).to eq(
        name: 'my-question',
        type: 'question',
        value: {
          id: card_content.id,
          title: 'What up?',
          answer_type: 'text',
          answer: 'Answer Value',
          attachments: []
        },
        children: []
      )
    end

    context 'when an answer has attachments' do
      let(:attachments_json) { serializer.as_json[:value][:attachments] }

      let(:attachment_1) do
        FactoryGirl.create(
          :question_attachment,
          :with_resource_token,
          status: QuestionAttachment::STATUS_DONE
        )
      end

      let(:attachment_2) do
        FactoryGirl.create(
          :question_attachment,
          :with_resource_token,
          status: QuestionAttachment::STATUS_DONE
        )
      end

      before do
        card_content.answers << FactoryGirl.build(
          :answer,
          owner: owner,
          value: 'The man was diseased with garrulity.',
          attachments: [attachment_1, attachment_2]
        )
      end

      it 'serializes answers with attachments' do
        expect(attachments_json.length).to eq 2

        expect(attachments_json[0]).to match hash_including(
          name: 'question-attachment',
          type: 'properties'
        )

        expect(attachments_json[0][:children]).to include(
          { name: 'id', type: 'integer', value: attachment_1.id },
          { name: 'file', type: 'text', value: attachment_1.filename },
          { name: 'title', type: 'text', value: attachment_1.title },
          { name: 'caption', type: 'text', value: attachment_1.caption },
          { name: 'status', type: 'text', value: attachment_1.status }
        )

        expect(attachments_json[1]).to match hash_including(
          name: 'question-attachment',
          type: 'properties'
        )
        expect(attachments_json[1][:children]).to include(
          { name: 'id', type: 'integer', value: attachment_2.id },
          { name: 'file', type: 'text', value: attachment_2.filename },
          { name: 'title', type: 'text', value: attachment_2.title },
          { name: 'caption', type: 'text', value: attachment_2.caption },
          { name: 'status', type: 'text', value: attachment_2.status }
        )
      end
    end
  end
end
