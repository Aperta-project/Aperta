require 'rails_helper'

describe AnswerContext do
  subject(:context) do
    AnswerContext.new(answer)
  end

  let(:answer) do
    FactoryGirl.build(:answer, card_content: card_content, value: true)
  end

  let(:card_content) do
    FactoryGirl.build(:card_content, value_type: value_type, text: "question")
  end

  let(:value_type) { 'boolean' }

  context 'rendering an answer' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'has a value_type' do
      check_render("{{ value_type }}", value_type)
    end

    it 'renders a string value' do
      check_render("{{ string_value }}", answer.string_value)
    end

    it 'renders a value' do
      check_render("{{ value }}", answer.value.to_s)
    end

    it 'renders a question' do
      check_render("{{ question }}", answer.card_content.text)
    end
  end
end
