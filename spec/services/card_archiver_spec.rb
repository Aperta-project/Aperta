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

describe CardArchiver do
  context ".archive" do
    it "sets the archived_at date of the card" do
      card = FactoryGirl.create(:card, state: "published")
      expect(card.archived_at).to be_nil
      CardArchiver.archive(card)
      expect(card.reload.archived_at).to be_present
    end

    it "does not change the date on already archived cards" do
      card = FactoryGirl.create(:card, :archived)
      expect { CardArchiver.archive(card) }.to_not change(card, :archived_at)
    end

    context "removing TaskTemplate records" do
      let(:card) { FactoryGirl.create(:card) }
      let!(:card_template) { FactoryGirl.create(:task_template, card: card, journal_task_type: nil) }
      let!(:other_template) { FactoryGirl.create(:task_template) }
      it "deletes any TaskTemplates that belong to the archived card" do
        expect { CardArchiver.archive(card) }.to change(TaskTemplate, :count).by(-1)
        expect(TaskTemplate.find_by(id: card_template.id)).to be_nil
      end
    end
  end
end
