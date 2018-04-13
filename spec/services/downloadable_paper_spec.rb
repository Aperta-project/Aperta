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

# Testing the generic case functionality brought in by the
# DownloadablePaper module
require 'rails_helper'

describe DownloadablePaper do
  let(:user) { create :user }
  let(:paper) { FactoryGirl.create :paper }

  # PDFConverter includes DownloadablePaper
  let(:pdf_converter) { PDFConverter.new(paper, user) }

  describe '#fs_filename' do
    it 'removes unwanted characters, but keeps wanted ones' do
      allow(paper).to receive(:display_title)
        .and_return '?*My* (over-kill)%#@ !=Title_&66'
      expect(pdf_converter.fs_filename)
        .to eq 'My (over-kill) Title_66.pdf'
    end

    it 'truncates to a safe length < 255' do
      title = ''
      20.times { title << '0123456789' }
      allow(paper).to receive(:display_title).and_return title
      expect(pdf_converter.fs_filename.length == 154)
        .to be(true)
    end
  end

  # these are generic paper_body cases, for specific cases, see the implmenting
  # classes themselves, PDFConverter, EpubConverter
  describe '#paper_body' do
    context 'when paper.body is empty' do
      it 'has empty message' do
        allow(paper).to receive(:body).and_return('')
        expect(pdf_converter.paper_body)
          .to eq 'The manuscript is currently empty.'
      end
    end

    context 'when paper.body is present and has no figures or supporting
      information' do
      it 'is just the paper.body' do
        allow(paper).to receive(:figureful_text).and_return('<b>body</b>')
        expect(pdf_converter.paper_body).to eq '<b>body</b>'
      end
    end
  end

  describe '#document_type' do
    it 'returns first word of converter type' do
      expect(PDFConverter.new(paper, user).document_type).to eq :pdf
    end
  end
end
