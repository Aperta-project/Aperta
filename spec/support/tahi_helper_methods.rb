module TahiHelperMethods
  def res_body
    JSON.parse(response.body)
  end

  def user_select_hash(user)
    {id: user.id, full_name: user.full_name, avatar: user.image_url}
  end

  def make_user_paper_admin(user, paper)
    assign_journal_role(paper.journal, user, :admin)
    paper_admin_task = paper.tasks.where(title: 'Assign Admin').first
    paper_admin_task.admin_id = user.id
    paper_admin_task.add_participant(user)
    paper_admin_task.save!
  end

  # NEW ROLES
  def assign_academic_editor_role(paper, user)
    FactoryGirl.create(:assignment,
                       role: paper.journal.academic_editor_role,
                       user: user,
                       assigned_to: paper)
  end

  def assign_author_role(paper, creator)
    creator.assign_to!(assigned_to: paper, role: paper.journal.creator_role)
  end

  def assign_task_participant_role(task, participant)
    participant.assign_to!(assigned_to: task, role: task.paper.journal.task_participant_role)
  end

  def assign_reviewer_role(paper, reviewer)
    reviewer.assign_to!(assigned_to: paper, role: paper.journal.reviewer_role)
  end

  def assign_handling_editor_role(paper, editor)
    editor.assign_to!(assigned_to: paper, role: paper.journal.handling_editor_role)
    # this is an old role:
    paper.paper_roles.create user: editor, old_role: PaperRole::EDITOR
  end

  def assign_internal_editor_role(paper, editor)
    editor.assign_to!(assigned_to: paper, role: paper.journal.internal_editor_role)
  end

  def assign_production_staff_role(journal, user)
    user.assign_to!(assigned_to: journal, role: paper.journal.production_staff_role)
  end

  def assign_publishing_services_role(journal, user)
    user.assign_to!(assigned_to: journal, role: paper.journal.publishing_services_role)
  end

  def assign_journal_role(journal, user, role_or_type)
    # New Roles
    if role_or_type == :admin
      user.assign_to!(assigned_to: journal, role: journal.staff_admin_role)
    elsif role_or_type == :editor
      user.assign_to!(assigned_to: journal, role: journal.internal_editor_role)
    end

    # Old Roles
    if role_or_type.is_a?(OldRole)
      old_role = role_or_type
      UserRole.create!(user: user, old_role: old_role).old_role
    else
      old_role = journal.old_roles.where(kind: role_or_type).first
      old_role ||= FactoryGirl.create(:old_role, role_or_type, journal: journal)
      UserRole.create!(user: user, old_role: old_role).old_role
    end
  end

  def with_aws_cassette(name)
    ignored_attributes = ["X-Amz-Algorithm", "X-Amz-Credential", "X-Amz-Date", "X-Amz-Expires", "X-Amz-Signature", "X-Amz-SignedHeaders"]
    VCR.use_cassette(name, match_requests_on: [:method, VCR.request_matchers.uri_without_params(*ignored_attributes)], record: :new_episodes) do
      yield
    end
  end

  def with_valid_salesforce_credentials
    sf_credentials       = Dotenv.load('.env.development').select{|k,v| k.include? 'DATABASEDOTCOM'}
    old_test_credentials = sf_credentials.inject({}){|hash, el| hash[el[0]] = ENV[el[0]]; hash }

    sf_credentials.each {|k,v| ENV[k] = v} #use real creds

    yield

    old_test_credentials.each {|k,v| ENV[k] = v} #reset to dummy creds
  end

  def register_paper_decision(paper, verdict)
    decision = paper.draft_decision
    task = paper.last_of_task(TahiStandardTasks::RegisterDecisionTask) ||
      create(:register_decision_task, paper: paper)

    decision.update! verdict: verdict
    decision.register!(task)
  end
end
