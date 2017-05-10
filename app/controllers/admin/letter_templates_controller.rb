# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    respond_with LetterTemplate.where(journal_id: params[:journal_id])
  end

  def show
    respond_with LetterTemplate.find(params[:id])
  end

  private

  def authorized_user
    requires_user_can(:administer, Journal)
  end
end
