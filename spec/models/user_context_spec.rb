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

describe UserContext do
  subject(:context) do
    UserContext.new(user)
  end

  let(:user) do
    FactoryGirl.build(:user)
  end

  let(:affiliation) do
    FactoryGirl.create(:affiliation, title: "Mister Manager", user: user)
  end

  context 'rendering a user' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'renders a first name' do
      check_render("{{ first_name }}", user.first_name)
    end

    it 'renders a last name' do
      check_render("{{ last_name }}", user.last_name)
    end

    it 'renders a full name' do
      check_render("{{ full_name }}", user.full_name)
    end

    it 'renders an email' do
      check_render("{{ email }}", user.email)
    end

    it 'renders a title' do
      check_render("{{ title }}", affiliation.title)
    end
  end
end
