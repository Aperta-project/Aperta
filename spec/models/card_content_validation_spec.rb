require 'rails_helper'

describe CardContentValidation do
  context 'validate' do
    context '#validate_answer' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          :with_string_match_validation, validator: 'org', violation_value: 'corgi')
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'pug') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'rollsback answer on validation failure' do
        expect(card_content_validation.validate_answer(answer))
        expect(answer.value).to eq 'corgi'
      end
    end

    context '#validate_by_string_match' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
                                                            :with_string_match_validation, validator: 'org')
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is valid if the string matches a simple regex' do
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'is valid with a more complex regex' do
        subject.update!(validator: '^\w{4}\.\d{7}$')
        answer.update(value: 'pbio.1000000')
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'is invalid if the string doesnt match' do
        answer.update!(value: 'eskie')
        expect(card_content_validation.validate_answer(answer)).to eq false
      end
    end

    context '#validate_by_answer_readiness' do
      let(:ident) { 'foodent' }
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          validation_type: 'answer_readiness',
          validator: 'true',
          error_message: 'that answer must be valid for this one to be valid :(',
          target_ident: ident)
      end

      let(:related_card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          :with_string_match_validation,
          validator: '42',
          error_message: 'Deep Thought disapproves!')
      end

      let(:card) { FactoryGirl.create(:card, card_contents: [card_content, related_card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner) }
      let(:related_answer) { FactoryGirl.create(:answer, owner: answer.task, value: '42') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [subject]) }
      let!(:related_card_content) {
        FactoryGirl.create(:card_content, answers: [related_answer], content_type: 'short-input', value_type: 'text',
                                          card_content_validations: [related_card_content_validation], ident: 'foodent')
      }

      it 'returns true if a related answer is valid' do
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'returns false if a related answer is invalid' do
        related_answer.update!(value: '9001')
        expect(card_content_validation.validate_answer(answer)).to eq false
      end
    end

    context '#validate_by_answer_value' do
      let(:ident) { 'foodent' }
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          validation_type: 'answer_value',
          validator: '42',
          error_message: 'that answer must be valid for this one to be valid :(',
          violation_value: true,
          target_ident: ident)
      end

      let(:related_card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          :with_string_match_validation,
          validator: '42',
          error_message: 'Deep thought disapproves (and that other answer too)!')
      end

      let(:card) { FactoryGirl.create(:card, card_contents: [card_content, related_card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner) }
      let(:related_answer) { FactoryGirl.create(:answer, owner: answer.task, value: '42') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [subject]) }
      let!(:related_card_content) {
        FactoryGirl.create(:card_content, answers: [related_answer], content_type: 'short-input', value_type: 'text',
                                          card_content_validations: [related_card_content_validation], ident: 'foodent')
      }

      it 'returns true if a related answer is valid' do
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'returns false if a related answer is invalid' do
        related_answer.update!(value: '9001')
        expect(card_content_validation.validate_answer(answer)).to eq false
      end
    end

    context '#validate_by_string_length_minimum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_minimum_validation)
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is invalid if validator string format is incorrect' do
        card_content_validation.validator = 'a string'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if validator string is a negative number' do
        card_content_validation.validator = '-1'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if answer length is less than minimum required' do
        card_content_validation.validator = '5'
        answer.value = 'abc'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if answer length is greater than minimum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcde'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end

    context '#validate_by_string_length_maximum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_maximum_validation)
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is invalid if validator string format is incorrect' do
        card_content_validation.validator = 'a string'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if validator string is a negative number' do
        card_content_validation.validator = '-1'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if answer length is greater than maximum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcdefgh'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if answer length is less than maximum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcd'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end
  end
end
