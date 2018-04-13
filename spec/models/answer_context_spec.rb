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
