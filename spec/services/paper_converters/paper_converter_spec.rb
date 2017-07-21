require 'rails_helper'

describe PaperConverters::PaperConverter do
  describe '::make' do
    subject { PaperConverters::PaperConverter.make(paper_version, export_format, current_user) }

    context 'the paper version type is pdf' do
      let(:paper_version) { create :paper_version, file_type: 'pdf' }
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

    context 'paper version type is docx' do
      let(:paper_version) { create :paper_version, file_type: 'docx' }
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

        it 'raises an error' do
          expect { subject }.to raise_error PaperConverters::UnknownConversionError
        end
      end
    end
  end
end
