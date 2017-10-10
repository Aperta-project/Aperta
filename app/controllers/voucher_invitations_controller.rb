# Handling the proecss flow of unauthenticated invitations.
class VoucherInvitationsController < ApplicationController
  before_action :ensure_invitation, only: :show

  respond_to :json

  def show
    render json: @invitation, root: 'voucher-invitation', serializer: ::VoucherInvitationsSerializer
  end

  def update
    @invitation = Invitation.find(params[:id])
    return unless voucher_invitation_declined?
    @invitation.update! decline_reason: voucher_invitation_decline_reason
    @invitation.decline!
    Activity.invitation_declined!(@invitation, user: nil)
    head :ok
  end

  private

  def ensure_invitation
    @invitation ||= Invitation.find_by(token: token)
  end

  def token
    params[:id]
  end

  def compiled_model
    {
      'voucher-invitation': {
        id: @invitation.id,
        invitation: @invitation,
        paper_title: @invitation.task.paper.title,
        paper_abstract: @invitation.task.paper.abstract,
        journal_logo_url: @invitation.task.paper.journal.logo_url
      }
    }
  end

  def voucher_invitation_params
    params.require(:voucher_invitation)
  end

  def voucher_invitation_declined?
    voucher_invitation_params.dig(:state) == 'declined'
  end

  def voucher_invitation_decline_reason
    voucher_invitation_params.dig(:decline_reason)
  end
end
