require 'spec_helper'

feature "Flow Manager", js: true, selenium: true do
  let(:admin) do
    create :user, :site_admin, first_name: "Admin"
  end

  let(:author) do
    create :user, :site_admin, first_name: "Author"
  end

  let(:journal) { FactoryGirl.create(:journal) }

  let!(:paper1) do
    FactoryGirl.create(:paper, :with_tasks,
      short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: author)
  end

  let!(:paper2) do
    FactoryGirl.create(:paper, :with_tasks,
      short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: journal,
      user: author)
  end

  def assign_tasks_to_user(paper, user, titles)
    paper.tasks.each { |t| t.participants << user if titles.include? t.title }
  end

  def complete_tasks(paper, titles)
    paper.tasks.each { |t| t.update(completed: true) if titles.include? t.title }
  end

  before do
    assign_journal_role(journal, admin, :admin)
    @old_size = page.driver.browser.manage.window.size
    page.driver.browser.manage.window.resize_to(1250,550)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  after do
    page.driver.browser.manage.window.size = @old_size
  end

  scenario "admin removes a column from their flow manager" do
    dashboard_page = DashboardPage.new
    flow_manager_page = dashboard_page.view_flow_manager
    up_for_grabs = flow_manager_page.column 'Up for grabs'
    up_for_grabs.remove

    expect(flow_manager_page).to have_no_column 'Up for grabs'
    expect(flow_manager_page).to have_no_application_error
  end

  scenario "admin adds a column to their flow manager" do
    dashboard_page = DashboardPage.new
    flow_manager_page = dashboard_page.view_flow_manager

    expect { flow_manager_page.add_column "Up for grabs" }.to change {
      flow_manager_page.columns("Up for grabs").count
    }.by(1)

    expect(flow_manager_page).to have_no_application_error
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
      within(".column", text: "My tasks") do
        expect(page).to have_css(".badge", text: "1")
      end
    end
  end

  context "PaperAdminTasks without assigned admin column placements" do
    before do
      paper1.tasks.where(type: "StandardTasks::PaperAdminTask").update_all(completed: false)
      paper2.tasks.where(type: "StandardTasks::PaperAdminTask").update_all(completed: false)
      assign_tasks_to_user(paper2, admin, ["Assign Admin"])

      dashboard_page = DashboardPage.new
      dashboard_page.view_flow_manager
    end

    scenario "papers with and without assigned admins" do
      within(".column", text: "Up for grabs") do
        expect(page).to have_content(paper1.title)
        expect(page).to have_no_content(paper2.title)
        expect(page).to have_content("Assign Admin")
      end
    end
  end

  context "PaperAdminTask column placements" do

    let(:unassociated_paper) do
      FactoryGirl.create(:paper, :with_tasks,
        short_title: 'unassociated',
        title: 'unassociated',
        submitted: true)
    end

    let(:unassigned_paper) do
      FactoryGirl.create(:paper, :with_tasks,
        short_title: 'unassigned',
        title: 'unassigned',
        submitted: true,
        journal: journal)
    end

    before do
      unassigned_paper.tasks.where(type: "StandardTasks::PaperAdminTask").update_all(completed: true)
      unassociated_paper.tasks.where(type: "StandardTasks::PaperAdminTask").update_all(completed: false)
      dashboard_page = DashboardPage.new
      dashboard_page.view_flow_manager
    end

    ["Up for grabs", "Done"].each do |phase_title|
      scenario "completed PaperAdminTasks should not be in #{phase_title} column" do
        within(".column", text: phase_title) do
          expect(page).to have_no_content(unassigned_paper.title)
        end
      end
    end

    scenario "unassociated paper admin task should not appear in the done column" do
      within(".column", text: "Up for grabs") do
        expect(page).to have_no_content(unassociated_paper.title)
      end
    end
  end


  context "an admin with papers assigned to them" do
    before do
      paper1.assign_role!(admin, PaperRole::ADMIN)
      paper2.assign_role!(admin, PaperRole::ADMIN)
    end

    scenario "Your Papers" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager

      my_papers = flow_manager_page.column 'My papers'
      papers = my_papers.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      papers.first.view # Verify that we can go to the paper's manage page from its profile.
    end

    scenario "Completing an assign admin task" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager
      my_papers = flow_manager_page.column 'My papers'
      first_paper_title = paper1.title

      my_papers.paper_profiles_for(first_paper_title)
      .first.view_card 'Assign Admin' do |card|
        card.mark_as_complete
        sleep 0.25
      end

      my_papers = flow_manager_page.column 'My papers'
      admin_card = my_papers.paper_profiles_for(first_paper_title).first.card_by_title('Assign Admin')
      expect(admin_card).to be_completed
    end

  end

  context "empty tasks" do
    scenario "there are no tasks" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager

      my_papers = flow_manager_page.column 'My papers'
      expect(my_papers.has_empty_text?).to eq(true)
    end
  end

  context "with tasks assigned and completed" do
    let(:paper1_task_titles) { ['Assign Editor', 'Tech Check', 'Assign Reviewers'] }
    let(:paper2_task_titles) { ['Assign Editor', 'Assign Reviewers', 'Upload Figures'] }
    let(:paper1_completed_task_titles) { ['Assign Editor', 'Tech Check'] }
    let(:paper2_completed_task_titles) { ['Upload Figures'] }

    before do
      assign_tasks_to_user(paper1, admin, paper1_task_titles)
      assign_tasks_to_user(paper2, admin, paper2_task_titles)
      complete_tasks(paper2, paper2_completed_task_titles)
      complete_tasks(paper1, paper1_completed_task_titles)
    end

    def my_task_expectations(flow_manager_page)
      my_tasks = flow_manager_page.column 'My tasks'
      papers = my_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      paper1_cards = papers.detect { |p| p.title == paper1.title }.cards
      paper2_cards = papers.detect { |p| p.title == paper2.title }.cards
      expect(paper1_cards.map &:title).to match_array (paper1_task_titles - paper1_completed_task_titles)
      expect(paper2_cards.map &:title).to match_array (paper2_task_titles - paper2_completed_task_titles)
      papers #return papers for later use
    end

    def completed_task_expectations(flow_manager_page)
      finished_tasks = flow_manager_page.column 'Done'
      papers = finished_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      paper1_profiles = finished_tasks.paper_profiles_for paper1.title
      paper2_profiles = finished_tasks.paper_profiles_for paper2.title
      paper1_cards = paper1_profiles.flat_map(&:cards)
      paper2_cards = paper2_profiles.flat_map(&:cards)
      expect(paper1_cards.map &:title).to match_array paper1_completed_task_titles
      expect(paper2_cards.map &:title).to match_array paper2_completed_task_titles
      papers #return papers for later use
    end

    scenario "Viewing the flow manager" do
      dashboard_page = DashboardPage.new
      flow_manager_page = dashboard_page.view_flow_manager
      my_task_expectations flow_manager_page
      completed_papers = completed_task_expectations flow_manager_page
      completed_papers.first.view # Verify that we can go to the paper's manage page from its profile.
    end
  end
end
