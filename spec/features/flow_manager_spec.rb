require 'rails_helper'

feature "Flow Manager", js: true, selenium: true do
  let(:admin) do
    create :user, :site_admin, first_name: "Admin"
  end

  let(:author) do
    create :user, :site_admin, first_name: "Author"
  end

  let!(:flow) do
    create :flow, title: "Up for grabs", query: { assigned: true }, old_role_id: nil
  end

  before do
    admin.flows << flow
    author.flows << flow

    @old_size = page.driver.browser.manage.window.size
    page.driver.browser.manage.window.resize_to(1250,550)
    login_as(admin, scope: :user)
    visit "/"
  end

  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

  let!(:paper1) do
    FactoryGirl.create(:paper, :submitted, :with_tasks,
      title: 'Foo bar',
      journal: journal,
      creator: author)
  end

  let!(:paper2) do
    FactoryGirl.create(:paper, :submitted, :with_tasks,
      title: 'Baz Qux',
      journal: journal,
      creator: author)
  end

  let!(:old_role) { assign_journal_role(journal, admin, :admin) }

  def assign_tasks_to_user(paper, user, titles)
    paper.tasks.each { |t| t.add_participant(user) if titles.include? t.title }
  end

  def complete_tasks(paper, titles)
    paper.tasks.each { |t| t.update(completed: true) if titles.include? t.title }
  end

  it "admin removes a column from their flow manager" do
    dashboard_page = DashboardPage.new
    flow_manager_page = dashboard_page.view_flow_manager
    up_for_grabs = flow_manager_page.column 'Up for grabs'
    up_for_grabs.remove

    expect(flow_manager_page).to have_no_column 'Up for grabs'
    expect(flow_manager_page).to have_no_application_error
  end

  context "adding a column to the flow manager" do
    it "the column should appear on the page" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager

      expect(flow_manager_page).to \
        have_css('.column h2', text: 'Up for grabs', count: 1)
      flow_manager_page.add_column 'Up for grabs'
      expect(flow_manager_page).to \
        have_css('.column h2', text: 'Up for grabs', count: 2)

      expect(flow_manager_page).to have_no_application_error
    end

    scenario "choices are determined by the user's flows" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager

      expect(flow_manager_page).to have_available_column("Up for grabs")
      expect(flow_manager_page.available_column_count).to eq(1)
    end
  end

  context "Comment count" do
    before do
      paper1.tasks.where(type: "TahiStandardTasks::PaperAdminTask").update_all(completed: false)
      task = paper1.tasks.where(type: "TahiStandardTasks::PaperAdminTask", completed: false).first

      task.add_participant(admin)
      task.comments << FactoryGirl.create(:comment, body: "Hi", commenter: FactoryGirl.create(:user))

      CommentLookManager.sync_task(task)

      dashboard_page = DashboardPage.new
      dashboard_page.view_flow_manager
    end

    it "displays unread comment count" do
      within(".column", text: "Up for grabs") do
        expect(page).to have_css(".badge", text: "1")
      end
    end
  end
end
