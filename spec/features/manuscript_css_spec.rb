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
require 'support/pages/paper_page'

feature "Manuscript CSS", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, manuscript_css: "background: magenta;" }

  before do
    paper
    login_as(author, scope: :user)
    visit "/"
    click_link(paper.title)
  end

  context "when editing the paper" do
    let(:paper) { FactoryGirl.create :paper, journal: journal, creator: author }

    scenario "CSS is applied when editing a paper" do
      edit_paper = PaperPage.new
      expect(edit_paper.css).to match /magenta/
    end
  end

  context "when the paper is submitted" do
    let(:paper) do
      FactoryGirl.create :paper, :submitted, journal: journal, creator: author
    end

    scenario "CSS is applied when viewing a paper" do
      paper_page = PaperPage.new
      expect(paper_page.css).to match /magenta/
    end
  end
end
