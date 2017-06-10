# Create an attachment for a correspondence
# Currently only for external correspondences
class ExternalCorrespondenceAttachment
  def create
    paper = Paper.find params[:external_correspondence_attachment][:paper_id]
    requires_user_can(:manage_workflow, paper)
    new_attach = ExternalCorrespondenceAttachment.new create_params
    new_attach.uploaded_by_id = current_user.id
    new_attach.save!
  end

  private

  def create_params
    params.require(:external_correspondence_attachment).permit(:filename,
                                                               :filetype,
                                                               :src,
                                                               :owner_type,
                                                               :owner_id,
                                                               :paper_id)
  end
end
