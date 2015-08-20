module TahiHelperMethods
  module FeatureHelpers
    def login_as(user)
      visit "/"
      fill_in "user[login]", with: user.username
      fill_in "user[password]", with: "password"
      page.click_button "Sign in"
      wait_for_ajax
    end

    def sign_out
      DashboardPage.new.sign_out
    end
  end

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

  def make_user_paper_editor(user, paper)
    assign_paper_role(paper, user, PaperRole::EDITOR)
  end

  def make_user_paper_reviewer(user, paper)
    assign_paper_role(paper, user, PaperRole::REVIEWER)
  end

  def assign_paper_role(paper, user, role)
    paper.paper_roles.create!(role: role, user: user)
    paper.reload
  end

  def assign_journal_role(journal, user, role_or_type)
    if role_or_type.is_a?(Role)
      role = role_or_type
    else
      role = journal.roles.where(kind: role_or_type).first
      role ||= FactoryGirl.create(:role, role_or_type, journal: journal)
    end
    UserRole.create!(user: user, role: role)
    role
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
