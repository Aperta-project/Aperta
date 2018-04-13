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

describe Answer do
  let(:card_content) { FactoryGirl.build(:card_content) }
  let(:value) { nil }
  subject(:answer) do
    FactoryGirl.build(
      :answer,
      card_content: card_content,
      value: value
    )
  end

  shared_examples_for :a_blank_answer do
    it { is_expected.to be_blank }
    it { is_expected.not_to be_present }
  end

  shared_examples_for :a_present_answer do
    it { is_expected.not_to be_blank }
    it { is_expected.to be_present }
  end

  context 'ReadyValidator - data-driven validations' do
    context 'string-match validation' do
      let(:card_content_validation) do
        FactoryGirl.create(:card_content_validation,
          :with_string_match_validation,
          card_content: card_content,
          validator: 'abby')
      end

      let(:value) { 'tabby' }

      it 'is valid when answer value matches the card content validator string' do
        subject.card_content.card_content_validations << card_content_validation
        subject.card_content.answers << answer
        expect(subject.ready?).to eq true
        expect(subject.ready).to eq true
        expect(subject.ready_issues).to eq []
      end

      it 'is not valid when answer value doesnt matches the card content validator string' do
        card_content_validation.update!(validator: 'notfindable')
        subject.card_content.card_content_validations << card_content_validation
        subject.card_content.answers << answer
        expect(subject.ready?).to eq false
        expect(subject.ready).to eq false
        expect(subject.ready_issues).to eq([card_content_validation.error_message])
      end
    end
  end

  context 'html sanitization' do
    let(:card_content) { FactoryGirl.create(:card_content, value_type: 'html') }

    it 'scrubs value if value_type is html' do
      answer.update!(value: "<div>something</div><foo>foo</foo><script>evilThing();</script>")
      answer.reload
      expect(answer.string_value).to eq "<div>something</div>fooevilThing();"
    end

    it 'leaves certain style attributes that we want to keep' do
      answer.update!(value: "<span>something</span><foo>foo</foo><script>evilThing();</script>")
      answer.reload
      expect(answer.string_value).to eq "<span>something</span>fooevilThing();"
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

      describe '#blank? works' do
        subject { value }
        context 'when the answer is nil' do
          let!(:value) { nil }
          it_behaves_like :a_blank_answer
        end

        context 'when the answer is "t"' do
          let!(:value) { "t" }
          it_behaves_like :a_present_answer
        end
      end
    end

    context 'the answer type is any other valid type' do
      it 'returns the value as a string with no coercion' do
        check_coercion('foo', 'foo')
        check_coercion(5, '5')
        check_coercion('true', 'true')
      end

      describe '#blank? works' do
        subject { value }
        context 'when the answer is nil' do
          let!(:value) { nil }
          it_behaves_like :a_blank_answer
        end

        context 'when the answer is a blank string' do
          let!(:value) { "" }
          it_behaves_like :a_blank_answer
        end

        context 'when the answer is "foo"' do
          let!(:value) { "t" }
          it_behaves_like :a_present_answer
        end
      end
    end

    context '#related_answers' do
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

    end
  end
end
