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
    FactoryGirl.create(:nested_question_answer, owner: task, paper: paper)
  end
  let(:task) do
    FactoryGirl.create(:task, paper: paper)
  end

  describe '#download!', vcr: { cassette_name: 'attachment' } do
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! knows when to keep and remove s3 files'
    it_behaves_like 'attachment#download! manages resource tokens'
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
