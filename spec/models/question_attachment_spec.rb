require 'rails_helper'

describe QuestionAttachment do
  let(:paper) { FactoryGirl.create(:paper_with_phases) }
  let(:question_attachment) do
    task = FactoryGirl.build(:task, paper: paper)
    answer = FactoryGirl.build(:nested_question_answer, owner: task, paper: paper)
    FactoryGirl.create(
      :question_attachment,
      owner: answer,
      file: File.open('spec/fixtures/yeti.tiff')
    )
  end

  describe '#paper' do
    it "returns the question's paper" do
      expect(question_attachment.paper).to eq(paper)
    end
  end

  describe '#src' do
    it 'returns nil when it is not done processing' do
      question_attachment.status = 'processing'
      expect(question_attachment.src).to be_nil
    end

    it 'returns a public non-expiring URL when processing is done' do
      question_attachment.status = 'done'
      expect(question_attachment.src).to eq(
        question_attachment.non_expiring_proxy_url
      )
    end
  end

end
