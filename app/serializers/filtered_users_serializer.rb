class FilteredUsersSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :avatar_url, :roles

  private

  def roles
    roles = object.paper_roles.where(paper_id: options[:paper_id])
    unless current_user.site_admin? || journal_admin?(current_user)
      roles = roles.where(role: PaperRole::COLLABORATOR)
    end
    roles.map(&:role)
  end

  def journal_admin?(user)
    paper = Paper.find_by(id: options[:paper_id])
    user.roles.where(journal: paper.journal, kind: "admin").present?
  end
end
