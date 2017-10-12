require 'rails_helper'

describe VoucherInvitationsController do
  let(:invited_invitation) { FactoryGirl.create :invitation, :invited }
  let(:declined_invitation) { FactoryGirl.create :invitation, :declined }
  let(:accepted_invitation) { FactoryGirl.create :invitation, :accepted }

  describe '#show' do
    context 'for `invited` invitations' do
      subject do
        get :show, format: :json, id: invited_invitation.token
      end
      it 'should return 200' do
        expect(subject).to have_http_status(200)
      end
    end

    context 'for `declined` invitations' do
      subject do
        get :show, format: :json, id: declined_invitation.token
      end

      it 'should return 404' do
        expect(subject).to have_http_status(404)
      end
    end

    context 'for `accepted` invitations' do
      subject do
        get :show, format: :json, id: accepted_invitation.token
      end

      it 'should return 404' do
        expect(subject).to have_http_status(404)
      end
    end
  end

  describe '#update' do
    context 'with a declined voucher invitation' do
      subject do
        put :update, format: :json, id: invited_invitation.id, voucher_invitation: { status: 'declined' }
      end

      it 'should decline the invitation' do
        subject
        expect(invitation.declined?).to be true
      end
    end
  end
end
