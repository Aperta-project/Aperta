require 'rails_helper'
describe RouterUploaderService do
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    params = {
      destination: 'fake-destination',
      email_on_failure: 'foo@bar.com',
      file_io: '',
      filenames: ['a.docx'],
      final_filename: 'b.zip',
      paper: paper,
      url: 'a/url',
      export_delivery_id: '1'
    }
    allow(TahiStandardTasks::ExportDelivery).to receive(:find).with('1')
    @service = RouterUploaderService.new(params)
  end

  describe '#aperta_id' do
    it 'returns the word aperta concatenated with a 7 digit string padded with zeros' do
      allow(paper).to receive(:id) { '1111' }
      expect(@service.aperta_id).to be == 'aperta.0001111'
    end
  end
end
