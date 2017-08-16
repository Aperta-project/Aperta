require 'rails_helper'

describe CardContentValidation do
  context 'validate' do
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

    context '#validate_html_by_length_minimum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_minimum_validation)
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: '<p>Test</p>') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation], value_type: 'html') }

      it 'is invalid if content doesn\'t meet minimum length when stripped of HTML tags' do
        card_content_validation.validator = '5'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if text content after HTML tags are stripped meets length requirement' do
        card_content_validation.validator = '4'
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

    context '#validate_html_by_length_maximum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_maximum_validation)
      end
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: '<p>Test</p>') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation], value_type: 'html') }

      it 'is invalid if content exceeds maximum length when stripped of HTML tags' do
        card_content_validation.validator = '3'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if text content after HTML tags doesn\'t exceed length maximum' do
        card_content_validation.validator = '4'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end
  end
end
