# Handling the proecss flow of unauthenticated invitations.
class VoucherInvitationsController < ApplicationController
  before_action :ensure_invitation

  respond_to :json

  def show; end

  private

  def ensure_invitation; end

  def voucher_invitation_params
    params.require(:voucher_invitation).permit(:token, :id)
  end
end
