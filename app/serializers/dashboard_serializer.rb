class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :total_paper_count, :total_page_count
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :administered_journals

  def id
    1
  end

  def total_paper_count
    total_paper_ids.length
  end

  def total_page_count
    (total_paper_count / Paper::PAGE_SIZE.to_f).ceil
  end

  def user
    @user ||= current_user
  end

  def administered_journals
    user.administered_journals
  end

  def papers
    return @papers if @papers
    roles = PaperRole.where(paper_id: total_paper_ids, user_id: user.id)
    papers = Paper.where(id: total_paper_ids).get_all_by_page(1).all

    # in this case N+1 queries are unavoidable without doing some grunt work ourselves..
    roles.group_by(&:paper_id).each do |paper_id, paper_roles|
      paper = papers.detect { |p| p.id == paper_id }
      #TODO: this is a temporary hack - fix with pivotal #75632076
      if paper.present?
        paper.role_descriptions = paper_roles.map(&:description)
      end
    end

    papers.each do |p|
      next unless p.user_id == user.id
      p.role_descriptions << "My Paper"
    end

    @papers = papers
  end

  private

  def total_paper_ids
    @ids ||= user.submitted_papers.pluck(:id) | user.assigned_papers.pluck(:id)
  end
end
