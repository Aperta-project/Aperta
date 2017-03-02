require 'rails_helper'

describe PaperConverters::PaperConverter do
  describe '::make' do
    subject { PaperConverters::PaperConverter.make(versioned_text, export_format) }

    context 'the versioned text type is pdf' do
      let(:versioned_text) { create :versioned_text, file_type: 'pdf' }

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

        # it would be great to move pdf conversion into this PaperConverters doo dad
        it 'raises an error' do
          expect { subject }.to raise_error PaperConverters::UnknownConversionError
        end
      end

      context 'the export format is pdf_with_attachments' do
        let(:export_format) { 'pdf_with_attachments' }

        it 'raises an error' do
          expect { subject }.to raise_error PaperConverters::UnknownConversionError
        end
      end
    end
  end
end
