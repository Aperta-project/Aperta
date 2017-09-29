# Handling the proecss flow of unauthenticated invitations.
class VoucherInvitationsController < ApplicationController
  before_action :ensure_invitation, only: :show

  respond_to :json

  def show
    return unless @invitation
    render json: @invitation, root: 'voucher-invitation', serializer: ::VoucherInvitationsSerializer
  end

  def update
    @invitation = Invitation.find_by(token: voucher_token)
    if voucher_invitation_declined?
      @invitation.update! decline_reason: voucher_invitation_decline_reason
      @invitation.decline!
      Activity.invitation_declined!(@invitation, user: nil)
      render json: @invitation, root: 'voucher-invitation', serializer: ::VoucherInvitationsSerializer
    else
      head :not_found
    end
  end

  private

  def ensure_invitation
    @invitation ||= Invitation.find_by(token: token)
  end

  def token
    params[:id]
  end

  def voucher_token
    voucher_invitation_params.dig(:token)
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
