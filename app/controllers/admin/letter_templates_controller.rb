# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    respond_with LetterTemplate.where(index_parameters)
  end

  private

  def authorized_user
    requires_user_can(:administer, Journal)
  end

  def index_parameters
    params.permit(:journal_id)
  end
end
