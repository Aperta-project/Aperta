#
# add comments
#
class SimilarityChecksController < ::ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def create
    requires_user_can(:perform_similarity_check, paper)
    similarity_check = SimilarityCheck.create!(
      versioned_text: versioned_text
    )
    similarity_check.start_report
    respond_with(similarity_check)
  end

  private

  def create_params
    @create_params ||= params.require(:similarity_check)
                         .permit(:versioned_text_id)
  end

  def paper
    versioned_text.paper
  end

  def versioned_text
    VersionedText.find(create_params[:versioned_text_id])
  end
end
