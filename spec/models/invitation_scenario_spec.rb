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

describe InvitationScenario do
  subject(:context) do
    InvitationScenario.new(invitation)
  end

  let(:paper) do
    FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
  end
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:invitation) { FactoryGirl.create(:invitation, :invited, paper: paper) }

  describe "rendering a template" do
    it "renders the journal" do
      template = "{{ journal.name }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(journal.name)
    end

    it "renders the manuscript type" do
      template = "{{ manuscript.paper_type }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.paper_type)
    end

    it "renders the manuscript title" do
      template = "{{ manuscript.title }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end

    it "renders the invitation status" do
      template = "{{ invitation.state }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(invitation.state)
    end

    it 'renders the declined reason (html safe)' do
      template = "{{ invitation.decline_reason }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(invitation.decline_reason.html_safe)
    end

    it 'renders the reviewer suggestions (html safe)' do
      template = "{{ invitation.reviewer_suggestions }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(invitation.reviewer_suggestions.html_safe)
    end
  end
end
