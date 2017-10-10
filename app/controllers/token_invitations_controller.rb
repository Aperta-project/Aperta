# Serves as the method for non-users to decline without having to sign in.
class TokenInvitationsController < ApplicationController
  before_action :redirect_if_logged_in, except: :accept
  before_action :redirect_unless_declined, except: [:show, :decline, :accept, :inactive]
  before_action :redirect_if_inactive, only: [:show, :accept, :decline]
  before_action :ensure_user!, only: [:accept], unless: :current_user

  # rubocop:disable Style/AndOr, Metrics/LineLength
  def show
    redirect_to root_path and return if invitation.accepted?

    assign_template_vars
  end

  def accept
    if invitation.invited? and current_user.email == invitation.email
      invitation.accept!
      Activity.invitation_accepted!(invitation, user: current_user)
      flash[:notice] = thank_you_message
    end
    redirect_to "/papers/#{invitation.paper.to_param}"
  end

  def decline
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

  def inactive
    assign_template_vars
    @email = @paper.journal.staff_email
  end

  private

  def assign_template_vars
    @invitation = invitation
    @paper = invitation.task.paper
    @journal_logo_url = @paper.journal.logo_url
  end

  def redirect_if_inactive
    redirect_to invitation_inactive_path(token) and return if invitation.declined? or invitation.rescinded?
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

  def thank_you_message
    journal_name = invitation.paper.journal.name
    base_message = if invitation.invitee_role == 'Reviewer'
                     "Thank you for agreeing to review for #{journal_name}."
                   else
                     "Thank you for agreeing to be an Academic Editor on this #{journal_name} manuscript."
                   end
    if params[:new_user]
      "Your PLOS account was successfully created. " + base_message
    else
      base_message
    end
  end

  def use_authentication?
    cas_phased_signup_disabled? or ned_unverified?
  end

  def cas_phased_signup_disabled?
    !TahiEnv.cas_phased_signup_enabled? or !FeatureFlag['CAS_PHASED_SIGNUP']
  end

  def ned_unverified?
    !NedUser.enabled? or NedUser.new.email_has_account?(invitation.email)
  end

  def ensure_user!
    if invitation.invitee_id or use_authentication?
      if TahiEnv.cas_enabled?
        redirect_to omniauth_authorize_path(:user, 'cas', url: akita_invitation_accept_url)
      else
        authenticate_user!
      end
    else
      # ok, they are in an env with cas and they aren't in aperta yet
      # let redirect them to CAS with with with the JWT payload and a
      # redirect url. Based on the current CAS signup endpoint, they
      # use a destination param for redirect after signup. We'll keep
      # that for now until instructed otherwise. We want to know if a
      # user is returning from a phased signup so our destination param
      # will have a query param of its own for the action to pickup and
      # use for setting our sweet flash message.

      # url inception ahead, beware
      cas_uri = URI.parse(TahiEnv.cas_phased_signup_url)

      cas_uri.query = { token: jwt_encoded_payload }.to_query
      store_location_for(:user, akita_invitation_accept_url(new_user: true))
      redirect_to cas_uri.to_s
    end
  end

  def akita_invitation_accept_url(query_hash = {})
    arg_hash = {
      controller: 'token_invitations',
      action: 'accept',
      token: invitation.token
    }
    url_for(arg_hash.merge(query_hash))
  end

  def akita_omniauth_callback_url
    url_for(
      controller: 'tahi_devise/omniauth_callbacks',
      action: 'cas',
      url: akita_invitation_accept_url(new_user: true)
    )
  end

  def jwt_encoded_payload
    payload = {
      destination: akita_omniauth_callback_url,
      email: invitation.email,
      heading: thank_you_message,
      subheading:
        "Before you begin your review in Aperta,\
        please take a moment to create your PLOS account."
    }
    # get key from env? Abstract this into its own service?
    private_key = OpenSSL::PKey::EC.new(TahiEnv.jwt_id_ecdsa, nil)
    JWT.encode(payload, private_key, 'ES256')
  end
end
