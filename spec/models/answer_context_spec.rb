require 'rails_helper'

describe AnswerContext do
  subject(:context) { AnswerContext.new(answer) }

  let(:answer) do
    FactoryGirl.build(:answer,
      card_content: FactoryGirl.build(:card_content, value_type: 'boolean', text: 'favorite color?', ident: 'foo--bar'),
      value: true)
  end

  context 'rendering an answer' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'renders a value_type' do
      check_render("{{ value_type }}", 'boolean')
    end

    it 'renders a string value' do
      check_render("{{ string_value }}", answer.string_value)
    end

    it 'renders a value' do
      check_render("{{ value }}", "true")
    end

    it 'renders a question' do
      check_render("{{ question }}", 'favorite color?')
    end

    it 'renders an ident' do
      check_render("{{ ident }}", 'foo--bar')
    end
  end
end
