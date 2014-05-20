module TahiHelperMethods
  def user_select_hash(user)
    {id: user.id, full_name: user.full_name, avatar: user.image_url}
  end

  def make_user_paper_admin(user, paper)
    assign_journal_role(paper.journal, user, :admin)
    paper_admin_task = paper.tasks.where(title: 'Assign Admin').first
    paper_admin_task.admin_id = user
    paper_admin_task.assignee = user
    paper_admin_task.save!
  end

  def assign_journal_role(journal, user, type)
    role = journal.roles.where(type => true).first
    role ||= FactoryGirl.create(:role, type)
    JournalRole.create!(journal: journal, user: user, role: role)
  end
end
