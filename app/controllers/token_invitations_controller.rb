# Serves as the method for non-users to decline without having to sign in.
class TokenInvitationsController < ApplicationController
  before_action :redirect_if_logged_in, except: :accept
  before_action :redirect_unless_declined, except: [:show, :decline, :accept]
  before_action :ensure_user!, only: [:accept]

  # rubocop:disable Style/AndOr, Metrics/LineLength
  def show
    redirect_to root_path and return if invitation.accepted?
    redirect_to invitation_feedback_form_path(token) and return if invitation.declined?

    assign_template_vars
  end

  def accept
    if invitation.invited? and current_user.email == invitation.email
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

  def ensure_user!
    # first we check if the user is already in our db
    # or if we even have that CAS_PHASED_SIGNUP_URL in this env
    if NedUser.new.email_has_account?(invitation.email) or !TahiEnv.cas_phased_signup_url
      # so they should login via regular means
      authenticate_user!
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
      cas_uri = URI.parse(ENV.fetch("CAS_SIGNUP_URL") || 'https://locahost:5000')
      invitation_accept_url = url_for(
        controller: 'token_invitations',
        action: 'accept',
        token: invitation.token,
        new_user: true
      )
      omniauth_callback = url_for(
        controller: 'tahi_devise/omniauth_callbacks',
        action: 'cas',
        url: invitation_accept_url
      )

      redirect_params = {
        service: omniauth_callback,
        token: jwt_encoded_payload
      }
      cas_uri.query = redirect_params.to_query
      redirect_to cas_uri.to_s
    end
  end

  def jwt_encoded_payload
    # payload = {
    #   email: invitation.email,
    #   heading: "Thank you for agreeing to review for PLOS Biology",
    #   subheading:
    #     "Before you begin your review in Aperta,\
    #     please take a moment to create your PLOS account."
    # }
    # # get key from env? Abstract this into its own service?
    # private_key = OpenSSL::PKey::EC.new(TahiEnv.phased_ec_key, nil)
    # JWT.encode(payload, private_key, 'ES256')
    SecureRandom.hex(20)
  end

end
