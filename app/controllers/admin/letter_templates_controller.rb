# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    journal_id = letter_template_params[:journal_id]
    letter_templates = LetterTemplate.where(journal_id: journal_id)
    respond_with(letter_templates, only: [:id, :subject, :name])
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

  def create
    journal = Journal.find(create_params[:journal_id])
    requires_user_can(:create_email_template, journal)
    template = LetterTemplate.create!(create_params)
    respond_with :admin, template
  end

  private

  def authorized_user
    requires_user_can(:manage_users, Journal)
  end

  def letter_template_params
    params.permit(:journal_id, letter_template: [:body, :subject, :name])
  end

  def create_params
    params.require(:letter_template).permit(:journal_id, :name, :scenario, :body, :subject)
  end
end
