require 'rails_helper'

describe QuestionAttachmentsController do

  expect_policy_enforcement

  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#show" do
    let!(:question_attachment) { FactoryGirl.create(:question_attachment) }
    subject(:do_request) do
      get :show, format: :json, id: question_attachment.id
    end

    it "succeeds" do
      do_request
      expect(response.status).to be(200)
    end

    it 'returns the question attachment' do
      do_request
      expect(res_body['question_attachment']['id']).to be(question_attachment.id)
    end
  end

  describe '#destroy' do
    let!(:question_attachment) { FactoryGirl.create(:question_attachment) }

    it 'destroys the question' do
      expect {
        put :destroy, format: :json, id: question_attachment.id
      }.to change { QuestionAttachment.count }.by(-1)
    end
  end

  describe '#create' do
    let!(:answer) { FactoryGirl.create(:nested_question_answer) }

    def do_request(params = {})
      post :create, format: :json, question_attachment: {
        nested_question_answer_id: answer.id,
        caption: 'This is a great caption!',
        src: 'http://some.cat.image.gif'
      }
    end

    it 'creates a new question attachment' do
      expect { do_request }.to change { answer.attachments.count }.by(1)

      attachment = answer.attachments.last
      expect(attachment.caption).to eq('This is a great caption!')
    end

    it 'processes the attachment in the background' do
      do_request
      question_attachment = answer.attachments.last
      expect(DownloadQuestionAttachmentWorker).to have_queued_job(
        question_attachment.id,
        'http://some.cat.image.gif'
      )
    end

    it 'returns json only including question_attachment id' do
      do_request
      question_attachment = answer.attachments.last
      expect(JSON.parse(response.body)).to eq({
        'question-attachment': { id: question_attachment.id }
      }.as_json)
    end
  end

  describe '#update' do
    let!(:answer) { FactoryGirl.create(:nested_question_answer) }
    let!(:question_attachment) do
      attrs = { nested_question_answer: answer }
      FactoryGirl.create :question_attachment, attrs
    end

    def do_request(params = {})
      put :update, format: :json, question_attachment: {
        caption: 'This is a great caption!', src: 'http://some.cat.image.gif'
      }, id: question_attachment.id
    end

    it 'updates a question attachment' do
      expect { do_request }.to_not change { answer.attachments.count }
      question_attachment.reload
      expect(question_attachment.caption).to eq('This is a great caption!')
    end

    it 'processes the attachment in the background' do
      do_request
      expect(DownloadQuestionAttachmentWorker).to have_queued_job(
        question_attachment.id,
        'http://some.cat.image.gif'
      )
    end

    it 'returns json only including question_attachment id' do
      do_request
      expect(JSON.parse(response.body)).to eq({
        'question-attachment': { id: question_attachment.id }
      }.as_json)
    end
  end
end
