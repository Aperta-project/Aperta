require 'rails_helper'

describe "update the Styleguide", js: true, selenium: true do

  let(:admin) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create(:journal) }
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let!(:mmt) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let!(:flow) do
    create :flow, title: "Up for grabs", query: { assigned: true }, role_id: nil
  end

  let!(:task) { FactoryGirl.create(:financial_disclosure_task, paper: paper) }

  # allows a block to retrieve its description - the it "is here description" do
  let(:name) do |e|
    e.description
  end

  before do
    admin.flows << flow
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

    scenario "flow_manager" do
      visit '/flow_manager'
      find(".control-bar-link", visible: true)
      page.grab(name)
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
      visit '/papers/1/manage'
      # also include an overlay
      has_css?(".card .card-content")
      card = first(".card .card-content")
      card.click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "paper_manager_overlay" do
      visit '/papers/1/manage'
      # also include an overlay
      has_css?(".card .card-content")
      card = first(".card .card-content")
      card.hover
      card.find(".card-remove").click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "financial-disclosure-card" do
      visit '/papers/1/manage'
      has_css?(".card .card-content")
      card = all(".card-content").last
      card.click
      first(".overlay--fullscreen", visible: true)
      first(".question-text", visible: true)
      first('input[name="financial_disclosure.commercially_affiliated"]').set(true)
      first('input[name="received-funding"]').set(true)
      page.grab(name)
    end

  end

end

class Capybara::Session
  def grab(filename, selector = "")
    # TODO: refactor: move this
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
