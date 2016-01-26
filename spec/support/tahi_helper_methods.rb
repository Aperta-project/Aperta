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
    paper_admin_task.participants << user
    paper_admin_task.save!
  end

  # OLD ROLES
  def make_user_paper_editor(user, paper)
    assign_paper_role(paper, user, PaperRole::EDITOR)
  end

  def make_user_paper_reviewer(user, paper)
    assign_paper_role(paper, user, PaperRole::REVIEWER)
  end

  def assign_paper_role(paper, user, old_role)
    paper.paper_roles.create!(old_role: old_role, user: user)
    paper.reload
  end

  # NEW ROLES
  def assign_author_role(paper, creator)
    DefaultAuthorCreator.new(paper, creator).create!
  end

  def assign_reviewer_role(paper, reviewer)
    Assignment.create(
      user: reviewer,
      role: Role.where(name: 'Reviewer').first,
      assigned_to: paper
    )
  end

  def assign_journal_role(journal, user, role_or_type)
    if role_or_type.is_a?(OldRole)
      old_role = role_or_type
    else
      old_role = journal.old_roles.where(kind: role_or_type).first
      old_role ||= FactoryGirl.create(:old_role, role_or_type, journal: journal)
    end
    UserRole.create!(user: user, old_role: old_role)
    old_role
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
