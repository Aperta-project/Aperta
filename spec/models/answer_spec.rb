require 'rails_helper'

describe Answer do
  subject(:answer) do
    FactoryGirl.build(:answer, card_content: card_content)
  end

  let(:card_content) do
    FactoryGirl.build(:card_content, value_type: value_type)
  end

  let(:value_type) { 'boolean' }

  context 'validation' do
    it 'is valid' do
      expect(answer).to be_valid
    end
  end

  context 'html sanitization' do
    let(:card_content) { FactoryGirl.create(:card_content, value_type: 'html') }
    subject(:answer) { FactoryGirl.create(:answer, card_content: card_content) }
    it 'scrubs value if value_type is html' do
      answer.update!(value: "<div>something</div><foo>foo</foo><script>evilThing();</script>")
      answer.reload
      expect(answer.string_value).to eq "<div>something</div>fooevilThing();"
    end
    it 'leaves certain style attributes that we want to keep' do
      answer.update!(value: "<span style='font-weight:bold;color: black;'>something</span><foo>foo</foo><script>evilThing();</script>")
      answer.reload
      expect(answer.string_value).to eq "<span style='font-weight:bold;'>something</span>fooevilThing();"
    end
  end

  context 'value' do
    def check_coercion(v, expected)
      answer.value = v
      expect(answer.value).to eq(expected)
    end

    context 'the answer type is boolean' do
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
