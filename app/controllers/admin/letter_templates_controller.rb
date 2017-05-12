# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    journal_id = letter_template_params[:journal_id]
    respond_with LetterTemplate.where(journal_id: journal_id)
  end

  private

  def authorized_user
    requires_user_can(:administer, Journal)
  end

  def letter_template_params
    params.permit(:journal_id)
  end
end
