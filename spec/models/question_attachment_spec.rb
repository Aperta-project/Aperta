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

describe QuestionAttachment do
  subject(:attachment) do
    FactoryGirl.create(
      :question_attachment,
      :with_resource_token,
      owner: answer,
      file: File.open('spec/fixtures/yeti.tiff')
    )
  end
  let(:paper) { FactoryGirl.create(:paper_with_phases) }
  let(:answer) do
    FactoryGirl.create(:answer, owner: task, paper: paper)
  end
  let(:task) do
    FactoryGirl.create(:ad_hoc_task, paper: paper)
  end

  describe '#download!', vcr: { cassette_name: 'attachment' } do
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! always keeps snapshotted files on s3'
    it_behaves_like 'attachment#download! manages resource tokens'
    it_behaves_like 'attachment#download! sets the updated_at'
    it_behaves_like 'attachment#download! sets the error fields'
    it_behaves_like 'attachment#download! when the attachment is invalid'
  end

  describe 'self.cover_letter' do
    it "returns question attachments whose answers' card contents have the 'cover_letter--attachment' ident" do
      paper = FactoryGirl.create(:paper)
      cover_letter_content = FactoryGirl.create(:card_content, ident: 'cover_letter--attachment')
      answer_to_find = FactoryGirl.create(:answer,
                                          paper: paper,
                                          card_content: cover_letter_content)
      other_content = FactoryGirl.create(:card_content, ident: 'foo')
      other_answer = FactoryGirl.create(:answer, paper: paper, card_content: other_content)
      a1 = FactoryGirl.create(:question_attachment, paper: paper, owner: answer_to_find)
      a2 = FactoryGirl.create(:question_attachment, paper: paper, owner: other_answer)

      letters = paper.reload.question_attachments.cover_letter.all
      expect(letters).to include(a1)
      expect(letters).to_not include(a2)
    end
  end

  describe '#paper' do
    it "returns the answer's paper" do
      expect(attachment.paper).to eq(answer.paper)
    end
  end

  describe '#src' do
    it 'returns nil when it is not done processing' do
      attachment.status = 'processing'
      expect(attachment.src).to be_nil
    end

    it 'returns a public non-expiring URL when processing is done' do
      attachment.status = described_class::STATUS_DONE
      expect(attachment.src).to eq(
        attachment.non_expiring_proxy_url
      )
    end
  end
end
