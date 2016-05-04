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
    Assignment.where(
      user: creator,
      role: paper.journal.creator_role,
      assigned_to: paper
    ).first_or_create!
  end

  def assign_reviewer_role(paper, reviewer)
    Assignment.where(
      user: reviewer,
      role: paper.journal.reviewer_role,
      assigned_to: paper
    ).first_or_create!
  end

  def assign_handling_editor_role(paper, editor)
    Assignment.where(
      user: editor,
      role: paper.journal.handling_editor_role,
      assigned_to: paper
    ).first_or_create!
    # this is an old role:
    paper.paper_roles.create user: editor, old_role: PaperRole::EDITOR
  end

  def assign_internal_editor_role(paper, editor)
    Assignment.where(
      user: editor,
      role: paper.journal.internal_editor_role,
      assigned_to: paper
    ).first_or_create!
  end

  def assign_production_staff_role(journal, user)
    Assignment.where(
      user: user,
      role: journal.production_staff_role,
      assigned_to: journal
    ).first_or_create!
  end

  def assign_publishing_services_role(journal, user)
    Assignment.where(
      user: user,
      role: journal.publishing_services_role,
      assigned_to: journal
    ).first_or_create!
  end

  def assign_journal_role(journal, user, role_or_type)
    # New Roles
    if role_or_type == :admin
      Assignment.where(
        user: user,
        role: journal.staff_admin_role,
        assigned_to: journal
      ).first_or_create!
    elsif role_or_type == :editor
      Assignment.where(
        user: user,
        role: journal.internal_editor_role,
        assigned_to: journal
      ).first_or_create!
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

end
