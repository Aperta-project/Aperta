class AdhocEmailsController < ActionController::Base
  include Authorizations

  def send_message
    AdhocMailer.delay.send_adhoc_email(params[:subject], params[:body], params[:recipients])
    head :ok
  end
end
