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
      expect(pdf_converter.fs_filename(ext: :pdf))
        .to eq 'My (over-kill) Title_66.pdf'
    end

    it 'truncates to a safe length < 255' do
      title = ''
      20.times { title << '0123456789' }
      allow(paper).to receive(:display_title).and_return title
      expect(pdf_converter.fs_filename(ext: :pdf).length == 154)
        .to be(true)
    end
  end

  # these are generic paper_body cases, for specific cases, see the implmenting
  # classes themselves, PDFConverter, EpubConverter
  describe '#paper_body' do
    context 'when paper.body is empty' do
      it 'has empty message' do
        expect(pdf_converter.send(:downloadable_templater))
          .to be_an_instance_of(ActionView::Base)
      end
    end

    context 'when paper.body is empty' do
      it 'is an instance of ActionView' do
        allow(paper).to receive(:body).and_return('')
        expect(pdf_converter.paper_body)
          .to eq 'The manuscript is currently empty.'
      end
    end

    context 'when paper.body is present and has no figures or supporting
      information' do
      it 'is just the paper.body' do
        allow(paper).to receive(:body).and_return('<b>body</b>')
        expect(pdf_converter.paper_body).to eq '<b>body</b>'
      end
    end

    context 'when paper has figures' do
      it 'does the right thing, which at the moment isnt clear' do
        # this will completed in https://developer.plos.org/jira/browse/APERTA-5741
      end
    end
  end

  describe '#downloadable_templater' do
    it 'is an instance of ActionView' do
      expect(pdf_converter.send(:downloadable_templater))
        .to be_an_instance_of(ActionView::Base)
    end
  end
end
