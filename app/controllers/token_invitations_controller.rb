# Serves as the method for non-users to decline without having to sign in.
class TokenInvitationsController < ApplicationController
  before_action :redirect_if_logged_in, except: :accept
  before_action :redirect_unless_declined, except: [:show, :decline, :accept]
  before_action :authenticate_user!, only: [:accept]

  # rubocop:disable Style/AndOr, Metrics/LineLength
  def show
    redirect_to root_path and return if invitation.accepted?
    redirect_to invitation_feedback_form_path(token) and return if invitation.declined?

    assign_template_vars
  end

  def accept
    if !invitation.accepted? and current_user.email == invitation.email
      invitation.accept!
      Activity.invitation_accepted!(invitation, user: current_user)
      journal_name = invitation.paper.journal.name
      flash[:notice] = "Thank you for agreeing to review for #{journal_name}."
    end
    redirect_to "/papers/#{invitation.paper.to_param}"
  end

  def decline
    redirect_to root_path and return if invitation.declined?
    redirect_to invitation_feedback_form_path(token)

    invitation.decline!
    Activity.invitation_declined!(invitation, user: nil)
  end

  def feedback_form
    if invitation.feedback_given?
      redirect_to invitation_thank_you_path(token) and return
    end

    assign_template_vars
  end

  def thank_you
    assign_template_vars
  end

  def feedback
    unless invitation.feedback_given?
      invitation.update_attributes(
        feedback_params
      )
    end

    redirect_to invitation_thank_you_path(token)
  end

  private

  def assign_template_vars
    @invitation = invitation
    @paper = invitation.task.paper
    @journal_logo_url = @paper.journal.logo_url
  end

  def redirect_if_logged_in
    redirect_to root_path if current_user
  end

  def redirect_unless_declined
    redirect_to root_path and return unless invitation.declined?
  end

  def feedback_params
    params
      .require(:invitation)
      .permit(:decline_reason,
        :reviewer_suggestions)
  end

  def token
    params[:token] || params[:invitation][:token]
  end

  def invitation
    @invitation ||= Invitation.find_by_token!(token)
  end
end
