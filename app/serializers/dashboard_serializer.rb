class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :administered_journals

  def id
    1
  end

  def user
    @user ||= current_user
  end

  def administered_journals
    user.administered_journals
  end

  def papers
    return @papers if @papers
    ids = user.submitted_papers.pluck(:id) | user.assigned_papers.pluck(:id)
    roles = PaperRole.where(paper_id: ids, user_id: user.id)
    papers = Paper.where(id: ids).all

    roles.group_by(&:paper_id).each do |paper_id, paper_roles|
      paper = papers.detect { |p| p.id == paper_id }
      paper.role_descriptions = paper_roles.map(&:description)
    end

    papers.each do |p|
      next unless p.user_id == user.id
      p.role_descriptions << "My Paper"
    end

    @papers = papers
    @papers
  end
end
