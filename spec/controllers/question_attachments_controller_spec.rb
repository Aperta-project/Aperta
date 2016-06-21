require 'rails_helper'

describe QuestionAttachmentsController do
  let(:user) { FactoryGirl.build_stubbed :user }
  let!(:question_attachment) do
    FactoryGirl.create(:question_attachment, owner: answer)
  end
  let(:answer) { FactoryGirl.create(:nested_question_answer, owner: task) }
  let(:task) { FactoryGirl.create(:task) }

  describe "#show" do
    subject(:do_request) do
      get :show, format: :json, id: question_attachment.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, question_attachment.owner.task)
          .and_return(true)
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

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, question_attachment.owner.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#destroy' do
    subject(:do_request) do
      put :destroy, format: :json, id: question_attachment.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, question_attachment.owner.task)
          .and_return(true)
      end

      it 'destroys the question' do
        expect do
          do_request
        end.to change { QuestionAttachment.count }.by(-1)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, question_attachment.owner.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#create' do
    let!(:answer) { FactoryGirl.create(:nested_question_answer, owner: task) }

    subject(:do_request) do
      post :create, format: :json, question_attachment: {
        nested_question_answer_id: answer.id,
        caption: 'This is a great caption!',
        src: 'http://some.cat.image.gif'
      }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(true)
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

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#update' do
    subject(:do_request) do
      put :update, format: :json, question_attachment: {
        caption: 'This is a great caption!', src: 'http://some.cat.image.gif'
      }, id: question_attachment.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(true)
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

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
