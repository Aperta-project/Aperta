require 'rails_helper'

describe Answer do
  let(:card_content) { FactoryGirl.build(:card_content) }
  subject(:answer) do
    FactoryGirl.build(
      :answer,
      card_content: card_content
    )
  end

  context 'ReadyValidator - data-driven validations' do
    context 'string-match validation' do
      let(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          :with_string_match_validation,
          card_content: card_content,
          validator: 'abby')
      end

      subject!(:answer) do
        FactoryGirl.create(
          :answer,
          value: 'tabby'
        )
      end

      it 'is valid when answer value matches the card content validator string' do
        subject.card_content.card_content_validations << card_content_validation
        subject.card_content.answers << answer
        expect(subject.ready?).to eq true
      end

      it 'is not valid when answer value doesnt matches the card content validator string' do
        card_content_validation.update!(validator: 'notfindable')
        subject.card_content.card_content_validations << card_content_validation
        subject.card_content.answers << answer
        expect(subject.ready?).to eq false
      end
    end
  end

  context 'value' do
    def check_coercion(v, expected)
      answer.value = v
      expect(answer.value).to eq(expected)
    end

    context 'the answer type is boolean' do
      let(:card_content) { FactoryGirl.create(:card_content, value_type: 'boolean') }

      it 'coerces truthy looking strings to true' do
        check_coercion('t', true)
        check_coercion('true', true)
        check_coercion('y', true)
        check_coercion('yes', true)
        check_coercion('1', true)
      end

      it 'coerces other values to false' do
        check_coercion('n', false)
        check_coercion('false', false)
        check_coercion('foo', false)
        check_coercion('', false)
        check_coercion('0', false)
      end
    end

    context 'the answer type is any other valid type' do
      let(:value_type) { 'text' }
      it 'returns the value as a string with no coercion' do
        check_coercion('foo', 'foo')
        check_coercion(5, '5')
        check_coercion('true', 'true')
      end
    end
  end
end
