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

    context 'when an answer has attachments' do
      let(:attachments_json) { serializer.as_json[:value][:attachments] }

      let(:attachment_1) do
        FactoryGirl.create(
          :question_attachment,
          status: QuestionAttachment::STATUS_DONE
        ).tap { |a| a.update_column :file, 'yeti-1.tiff' }
      end

      let(:attachment_2) do
        FactoryGirl.create(
          :question_attachment,
          status: QuestionAttachment::STATUS_DONE
        ).tap { |a| a.update_column :file, 'yeti-2.tiff' }
      end

      before do
        nested_question.nested_question_answers << FactoryGirl.build(
          :nested_question_answer,
          owner: owner,
          value: 'The man was diseased with garrulity.',
          attachments: [attachment_1, attachment_2]
        )
      end

      it 'serializes questions with attachments' do
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
