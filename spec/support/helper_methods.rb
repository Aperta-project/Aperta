module TahiHelperMethods
  def user_select_hash(user)
    {id: user.id, full_name: user.full_name, avatar: user.image_url}
  end

  def make_user_paper_admin(user, paper)
    assign_journal_role(paper.journal, user, :admin)
    paper_admin_task = paper.tasks.where(title: 'Assign Admin').first
    paper_admin_task.admin_id = user.id
    paper_admin_task.participants << user
    paper_admin_task.save!
  end

  def make_user_paper_editor(user, paper)
    assign_journal_role(paper.journal, user, :editor)
    editor_task = paper.tasks.where(title: 'Assign Editor').first
    editor_task.editor_id = user.id
  end

  def assign_journal_role(journal, user, type)
    role = journal.roles.where(kind: type).first
    role ||= FactoryGirl.create(:role, type, journal: journal)
    UserRole.create!(user: user, role: role)
    role
  end

  def with_aws_cassette(name)
    VCR.use_cassette(name, match_requests_on: [:method, VCR.request_matchers.uri_without_params(:AWSAccessKeyId, :Expires, :Signature)], record: :new_episodes) do
      yield
    end
  end
end
