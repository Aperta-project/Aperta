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

describe PaperConverters::PaperConverter do
  describe '::make' do
    subject { PaperConverters::PaperConverter.make(versioned_text, export_format, current_user) }

    context 'the versioned text type is pdf' do
      let(:versioned_text) { create :versioned_text, file_type: 'pdf' }
      let(:current_user) { create :user }

      context 'the export format is nil' do
        let(:export_format) { nil }

        it { is_expected.to be_an_instance_of PaperConverters::IdentityPaperConverter }
      end

      context 'the export format is pdf' do
        let(:export_format) { 'pdf' }

        it { is_expected.to be_an_instance_of PaperConverters::IdentityPaperConverter }
      end

      context 'the export format is docx' do
        let(:export_format) { 'docx' }

        it 'raises an error' do
          expect { subject }.to raise_error PaperConverters::UnknownConversionError
        end
      end

      context 'the export format is pdf_with_attachments' do
        let(:export_format) { 'pdf_with_attachments' }

        it { is_expected.to be_an_instance_of PaperConverters::PdfWithAttachmentsPaperConverter }
      end
    end

    context 'versioned text type is docx' do
      let(:versioned_text) { create :versioned_text, file_type: 'docx' }
      let(:current_user) { create :user }

      context 'the export format is nil' do
        let(:export_format) { nil }

        it { is_expected.to be_an_instance_of PaperConverters::IdentityPaperConverter }
      end

      context 'the export format is docx' do
        let(:export_format) { 'docx' }

        it { is_expected.to be_an_instance_of PaperConverters::IdentityPaperConverter }
      end

      context 'the export format is pdf' do
        let(:export_format) { 'pdf' }

        it { is_expected.to be_an_instance_of PaperConverters::PdfPaperConverter }
      end

      context 'the export format is pdf_with_attachments' do
        let(:export_format) { 'pdf_with_attachments' }

        it { is_expected.to be_an_instance_of PaperConverters::PdfPaperConverter }
      end
    end
  end
end
