def user_select_hash(user)
  {id: user.id, full_name: user.full_name, avatar: user.image_url}
end

def make_user_journal_admin(user, paper)
  JournalRole.create! admin: true, journal: paper.journal, user: user
end

def make_user_paper_admin(user, paper)
  make_user_journal_admin(user, paper)
  paper_admin_task = paper.tasks.where(title: 'Assign Admin').first
  paper_admin_task.admin_id = user
  paper_admin_task.assignee = user
  paper_admin_task.save!
end
