require 'spec_helper'

feature "Flow Manager", js: true, selenium: true do
  let(:admin) do
    create :user, :site_admin, first_name: "Admin"
  end

  let(:author) do
    create :user, :site_admin, first_name: "Author"
  end

  let!(:flow) do
    create :flow, title: "Up for grabs", assigned_query: true, role_id: nil
  end

  before do
    admin.flows << flow
    author.flows << flow
  end

  let(:journal) { FactoryGirl.create(:journal) }

  let!(:paper1) do
    FactoryGirl.create(:paper, :with_tasks,
      short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      creator: author)
  end

  let!(:paper2) do
    FactoryGirl.create(:paper, :with_tasks,
      short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: journal,
      creator: author)
  end

  let!(:role) { assign_journal_role(journal, admin, :admin) }

  def assign_tasks_to_user(paper, user, titles)
    paper.tasks.each { |t| t.participants << user if titles.include? t.title }
  end

  def complete_tasks(paper, titles)
    paper.tasks.each { |t| t.update(completed: true) if titles.include? t.title }
  end

  before do
    @old_size = page.driver.browser.manage.window.size
    page.driver.browser.manage.window.resize_to(1250,550)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  after do
    page.driver.browser.manage.window.size = @old_size
  end

  it "admin removes a column from their flow manager" do
    dashboard_page = DashboardPage.new
    flow_manager_page = dashboard_page.view_flow_manager
    up_for_grabs = flow_manager_page.column 'Up for grabs'
    up_for_grabs.remove

    expect(flow_manager_page).to have_no_column 'Up for grabs'
    expect(flow_manager_page).to have_no_application_error
  end

  context "column header" do
    before do
      # force relationship to satisfy a Users's user_flows payload
      flow.update(role_id: 1)
    end

    context "journal without logo" do
      it "show journal name as text" do
        visit "/flow_manager"
        expect(page).to have_css ".column-title-wrapper"
        within ".column-title-wrapper" do
          expect(page).to have_content journal.name
        end
      end
    end

    context "journal with logo" do
      before do
        with_aws_cassette(:yeti_image) do
          journal.update_attributes(logo: File.open("spec/fixtures/yeti.jpg"))
        end
      end

      it "show journal logo" do
        visit "/flow_manager"
        find(".column-header")
        expect(page).to have_css ".column-title-wrapper"
        within ".column-title-wrapper" do
          expect(page).to have_css("img")
        end
      end
    end
  end

  context "adding a column to the flow manager" do
    it "the column should appear on the page" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager

      expect { flow_manager_page.add_column "Up for grabs" }.to change {
        flow_manager_page.columns("Up for grabs").count
      }.by(1)

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
      paper1.tasks.where(type: "StandardTasks::PaperAdminTask").update_all(completed: false)
      task = paper1.tasks.where(type: "StandardTasks::PaperAdminTask", completed: false).first

      task.participants << admin
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
