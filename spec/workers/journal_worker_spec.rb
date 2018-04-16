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
RSpec.describe JournalWorker, type: :worker do
  describe JournalWorker do
    subject(:worker) { JournalWorker.new }
    let(:loader) { CustomCard::FileLoader }
    let(:journal) do
      JournalFactory.create(
        name: 'Journal of the Stars',
        doi_journal_prefix: 'journal.SHORTJPREFIX1',
        doi_publisher_prefix: 'SHORTJPREFIX1',
        last_doi_issued: '1000001'
      )
    end

    let!(:user) { FactoryGirl.create(:user) }
    let(:orcid_account) { user.orcid_account }

    it 'calls update profile' do
      expect(loader).to receive(:load)
      expect(Journal).to receive(:find) { journal }
      worker.perform(journal.id)
    end
  end
end
