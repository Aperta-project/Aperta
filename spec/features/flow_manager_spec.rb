require 'spec_helper'

feature "Flow Manager" do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end

  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end


  scenario "My Tasks column" do
    paper1_task_titles = ['Assign Editor']
    paper2_task_titles = ['Assign Editor', 'Tech Check']
    paper1 = author.papers.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: Journal.create!
    paper1.tasks.each { |t| t.update(assignee: admin) if paper1_task_titles.include? t.title }
    paper2 = author.papers.create! short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: Journal.create!
    paper1.tasks.each { |t| t.update(assignee: admin) if paper2_task_titles.include? t.title }

    dashboard_page = DashboardPage.visit
    flow_manager_page = dashboard_page.view_flow_manager
    my_tasks = flow_manager_page.column 'My Tasks'
    papers = my_tasks.papers
    expect(papers.map &:title).to eq [paper1.title, paper2.title]
    paper1_cards = papers.detect { |p| p.title == paper1.title }.cards
    paper2_cards = papers.detect { |p| p.title == paper2.title }.cards
    expect(paper1_cards.map &:title).to eq paper1_task_titles
    expect(paper2_cards.map &:title).to eq paper2_task_titles
  end
end
