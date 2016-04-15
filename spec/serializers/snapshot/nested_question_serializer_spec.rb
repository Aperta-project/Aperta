require 'rails_helper'

describe Snapshot::NestedQuestionSerializer do
  subject(:serializer) { described_class.new(nested_question, owner) }
  let(:nested_question) do
    FactoryGirl.create(:nested_question, ident: 'my-question', text: 'What up?')
  end
  let(:owner) { FactoryGirl.create(:task) }

  describe '#as_json - serializing nested questions' do
    it 'serializes the question without an answer' do
      expect(serializer.as_json).to eq(
        name: 'my-question',
        type: 'question',
        value: {
          id: nested_question.id,
          title: 'What up?',
          answer_type: 'text',
          answer: nil,
          attachments: []
        },
        children: []
      )
    end

    context 'when it has child questions' do
      before do
        nested_question.children << FactoryGirl.create(
          :nested_question,
          ident: '1st_question',
          text: '1st level child question',
          children: [
            FactoryGirl.build(
              :nested_question,
              ident: '2nd_question',
              text: '2nd level child question'
            )
          ]
        )
      end

      it 'serializes children questions' do
        expect(serializer.as_json).to eq(
          name: 'my-question',
          type: 'question',
          value: {
            id: nested_question.id,
            title: 'What up?',
            answer_type: 'text',
            answer: nil,
            attachments: []
          },
          children: [{
            name: '1st_question',
            type: 'question',
            value: {
              id: nested_question.children.first.id,
              title: '1st level child question', answer_type: 'text',
              answer: nil, attachments: []
            },
            children: [{
              name: '2nd_question',
              type: 'question',
              value: {
                id: nested_question.children.first.children.first.id,
                title: '2nd level child question', answer_type: 'text',
                answer: nil, attachments: []
              },
              children: []
            }]
          }]
        )
      end
    end

    it 'serializes questions with an answer' do
      FactoryGirl.create(
        :nested_question_answer,
        owner: owner,
        value: 'Answer Value',
        nested_question: nested_question
      )

      expect(serializer.as_json).to eq(
        name: 'my-question',
        type: 'question',
        value: {
          id: nested_question.id,
          title: 'What up?',
          answer_type: 'text',
          answer: 'Answer Value',
          attachments: []
        },
        children: []
      )
    end

    it 'serializes questions with attachments as answers' do
      attachment = FactoryGirl.build(
        :question_attachment,
        :with_fake_attachment
      )
      nested_question.nested_question_answers << FactoryGirl.build(
        :nested_question_answer,
        owner: owner,
        value: 'The man was diseased with garrulity.',
        attachments: [attachment]
      )

      expect(serializer.as_json[:value][:attachments]).to eq([
        name: 'question-attachment',
        type: 'properties',
        children: [
          { name: 'id', type: 'integer', value: attachment.id },
          { name: 'file', type: 'text', value: 'some-attachment.png' },
          { name: 'title', type: 'text', value: nil },
          { name: 'caption', type: 'text', value: nil },
          { name: 'status', type: 'text', value: nil }
        ]
      ])
    end
  end
end
