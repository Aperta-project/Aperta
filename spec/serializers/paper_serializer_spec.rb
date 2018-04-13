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

describe PaperSerializer do
  subject(:serializer) { described_class.new(paper, user: user, root: :paper) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  before do
    allow(paper).to receive_messages(
      active: true,
      created_at: 'created_at_date',
      editable: true,
      id: 99,
      journal_id: 117,
      manuscript_id: 'doi.111',
      processing: true,
      publishing_state: 'unsubmitted',
      role_descriptions_for: [],
      title: 'The great paper'
    )
  end

  describe 'a paper created by a user' do
    let(:json) { serializer.as_json[:paper] }

    let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }

    let(:paper) do
      FactoryGirl.create(:paper, journal: journal, creator: user, preprint_doi_article_number: "1234567")
    end

    describe 'aarx_doi' do
      it "should be present" do
        expect(json[:aarx_doi].to_s).to be_present
        expect(json[:aarx_doi].to_s).to eq("10.24196/aarx.1234567")
      end
    end

    describe 'related_at_date' do
      let!(:one_day_ago) { 1.day.ago }
      let!(:two_days_ago) { 2.days.ago }

      context 'when the user has been assigned to this paper' do
        before do
          allow(paper).to receive(:roles_for)
            .with(user: user)
            .and_return [double(created_at: one_day_ago), double(created_at: two_days_ago)]
        end

        it "serializes to the user's latest role assignment to this paper" do
          expect(json[:related_at_date].to_s).to eq(one_day_ago.to_s)
        end
      end

      context 'when the use has not been assigned to this paper' do
        before do
          allow(paper).to receive(:roles_for)
            .with(user: user)
            .and_return []
        end

        it "serializes to nil" do
          expect(json).to match hash_including(related_at_date: nil)
        end
      end

      context 'when there is no user' do
        subject(:serializer) { described_class.new(paper, user: nil, root: :paper) }

        it 'is serialized as nil' do
          expect(json).to match hash_including(related_at_date: nil)
        end
      end
    end
  end
end
