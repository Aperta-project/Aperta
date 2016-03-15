class FilteredUserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :avatar_url, :old_roles

  private

  def old_roles
    old_roles = object.paper_roles.where(paper_id: options[:paper_id])
    unless current_user.site_admin? || journal_admin?(current_user)
      old_roles = old_roles.where(old_role: PaperRole::COLLABORATOR)
    end
    old_roles.map(&:old_role)
  end

  def journal_admin?(user)
    paper = Paper.find_by(id: options[:paper_id])
    user.can?(:administer, paper.journal)
  end
end
