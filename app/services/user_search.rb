class UserSearch
  def self.collaborators(paper_id)
    Paper.find(paper_id).try(:assigned_users)
  end

  def self.non_participants(task_id)
    User.joins(:participations).where.not(participations: { task_id: task_id })
  end

  def self.participants(task_id)
    User.joins(:participations).where(participations: { task_id: task_id })
  end
end
