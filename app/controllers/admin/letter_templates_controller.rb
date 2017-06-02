# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    journal_id = letter_template_params[:journal_id]
    letter_templates = LetterTemplate.where(journal_id: journal_id)
    respond_with(letter_templates, only: [:id, :subject, :text])
  end

  def show
    respond_with LetterTemplate.find(params[:id])
  end

  def update
    letter_template = LetterTemplate.find(params[:id])
    update_params = letter_template_params[:letter_template]
    letter_template.update(update_params)
    respond_with letter_template
  end

  private

  def authorized_user
    requires_user_can(:administer, Journal)
  end

  def letter_template_params
    params.permit(:journal_id, letter_template: [:letter, :subject])
  end
end
