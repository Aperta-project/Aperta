require 'rails_helper'

describe "update the Styleguide", js: true, selenium: true do

  let(:admin) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create(:journal) }
  let!(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:paper2) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let!(:mmt) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let!(:flow) do
    create :flow, title: "Up for grabs", query: { assigned: true }, role_id: nil
  end

  # allows a block to retrieve its description - the it "is here description" do
  let(:name) do |e|
    e.description
  end

  before do
    # Create all the tasks at once
    FactoryGirl.create(:task, paper: paper)
    FactoryGirl.create(:plos_authors_task, paper: paper)
    FactoryGirl.create(:competing_interests_task, paper: paper)
    FactoryGirl.create(:data_availability_task, paper: paper)
    FactoryGirl.create(:ethics_task, paper: paper)
    FactoryGirl.create(:figure_task, paper: paper)
    FactoryGirl.create(:financial_disclosure_task, paper: paper)
    FactoryGirl.create(:paper_admin_task, paper: paper)
    FactoryGirl.create(:paper_editor_task, paper: paper)
    FactoryGirl.create(:paper_reviewer_task, paper: paper)
    FactoryGirl.create(:publishing_related_questions_task, paper: paper)
    FactoryGirl.create(:register_decision_task, paper: paper)
    FactoryGirl.create(:reporting_guidelines_task, paper: paper)
    FactoryGirl.create(:reviewer_report_task, paper: paper)
    FactoryGirl.create(:taxon_task, paper: paper)
    FactoryGirl.create(:tech_check_task, paper: paper)
    FactoryGirl.create(:supporting_information_task, paper: paper)
    FactoryGirl.create(:upload_manuscript_task, paper: paper)

    # Do the normal stuff
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "save HTML and .pngs for every page in the App" do
    scenario "dashboard" do
      visit '/'
      page.grab(name)
    end

    scenario "navigation" do
      visit '/'
      find(".navigation-toggle").click
      find(".navigation", visible: true)
      page.grab(name, ".navigation")
    end

    describe "flow_manager" do
      before do
        admin.flows << flow
      end

      scenario "stuff" do
        visit '/flow_manager'
        find(".control-bar-link", visible: true)
        page.grab(name)
      end
    end

    scenario "admin" do
      visit '/admin'
      find(".journals", visible: true)
      page.grab(name)
    end

    # TODO
    scenario "paper" do
      visit '/papers/1/edit'
      find(".manuscript-container", visible: true)
      page.grab(name)
    end

    scenario "paper_contributors" do
      visit '/papers/1/edit'
      find(".manuscript-container", visible: true)
      find(".contributors-link").click
      find(".contributors.active")
      page.grab(name)
    end

    scenario "paper_download_document" do
      visit '/papers/1/edit'
      find(".manuscript-container", visible: true)
      find(".downloads-link").click
      find(".manuscript-download-links.active")
      page.grab(name)
    end

    scenario "journal_admin" do
      visit "/admin/journals/#{journal.id}"
      has_css?(".mmt-thumbnail")
      first_mmt = first(".mmt-thumbnail")
      first_mmt.hover
      find(".glyphicon-trash", visible: true)
      page.grab(name)
    end

    scenario "paper_manager" do
      Task.first.update(completed: true)
      visit '/papers/2/manage'
      has_css?(".card .card-content")
      card = first(".card .card-content")
      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "card_ad_hoc" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Do something awesome')
      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "card_plos_authors_task" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Add Authors')
      card.click
      first(".overlay", visible: true)
      find(".button-primary").click
      find(".add-author-form", visible: true)

      page.grab(name)
    end

    scenario "card_competing_interests" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Competing Interests')
      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "card_data_availability" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Data Availability')
      card.click
      first(".overlay", visible: true)
      all(".item input").last.click
      find(".additional-data", visible: true)
      page.grab(name)
    end

    scenario "card_ethics" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Ethics')

      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "card_figure" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Upload Figures')

      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "card_financial_disclosure" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Financial Disclosure')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_paper_admin_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Assign Admin')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_paper_editor_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Assign Editor')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_paper_reviewer_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Assign Reviewers')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_publishing_related_questions_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Publishing Related Questions')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_register_decision_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Register Decision')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_reporting_guidelines_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Reporting Guidelines')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_reviewer_report_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Reviewer Report')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_taxon_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Taxon')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_tech_check_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Tech Check')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_supporting_information_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Supporting Information')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "card_upload_manuscript_task" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = find(".card-content", text: 'Upload Manuscript')
      card.click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "paper_manager_overlay" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = first(".card .card-content")
      card.hover
      card.find(".card-remove").click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

  end

end

class Capybara::Session
  def grab(filename, selector = "")
    dirname = "doc/ux"
    FileUtils.mkdir_p(dirname)

    save_html("#{dirname}/#{filename}", selector)
    save_screenshot("#{dirname}/#{filename}.png")

    p "Saving HTML and a Screenshot for", filename
  end


  private

  def save_html(filename, selector = "")
    return unless filename

    first("body div")
    # find a UI element instead of waiting
    sleep 2.0

    File.open("#{filename}.html", "w") do |f|
      if !selector.empty?
        f << Nokogiri::HTML(html).css(selector).try(:to_html)
      else
        f << self.html
      end
    end
  end
end
