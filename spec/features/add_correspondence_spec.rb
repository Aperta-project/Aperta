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

feature "Adding correspondence", js: true, sidekiq: :inline! do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:correspondence_one) do
    FactoryGirl.create(:correspondence, paper: paper)
  end

  before do
    allow(user).to receive(:can?)
      .with(:manage_workflow, paper)
      .and_return true

    assign_journal_role(journal, user, :admin)
    login_as(user)
    visit "/papers/#{paper.id}/correspondence"
  end

  describe "Correspondence list receives pushed update" do
    let!(:correspondence_two) do
      FactoryGirl.build(:correspondence, paper: paper)
    end

    it "Updates view with new correspondence when db record created" do
      expect(page).to have_css('tbody > tr', count: 1)
      correspondence_two.save!
      expect(page).to have_css('tbody > tr', count: 2)
    end
  end
end
