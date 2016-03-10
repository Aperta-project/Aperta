# Task types are displayed on the paper workflow page
class PaperTaskTypesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:manage_workflow, paper)
    respond_with JournalTaskType.where(journal_id: paper.journal.id)
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end
end
