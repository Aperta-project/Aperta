# THIS IS SORTA THE STYLEGUIDE README FOR NOW
#
# High-Level UX/Design Notes (Communicating Design)
#
# An App has:
# * Use Cases
#     In order to meet a Use Case, a User completes a Flow
# * User Flows.
#     A User Flow is made up of screens that are designed to accomplish a Use Case.
# * Screens
#     A Screen is a complete web page (or state of a page) where a User can do something
#     Layout
#        A common html page, that might have Components too (TODO: make this more clear)
#     Component
#       Custom sets of HTML Elements, plus styling, plus .js behavior
#     Element
#       Base level HTML Markup. A single instance of <div>s and <span>s and <p>, etc.


# The goal of this project is to generate a Complete Styleguide for Tahi, that can
# be completely updated with minimal effort.

# To accomplish this, we will create a Styleguide page that will have placeholders
# for certain components.
# A script will then look at Tahi-Staging and pull live
# markup from Tahi-Staging and paste it into the Styleguide.
# When the script is run again,
# the pasted in Markup is refreshed, accordingly.

# This could be done with Comments blocks,
# or even a custom element that can have its contents replaced.
#
#

# THE STYLEGUIDE ***************************************************************
# This file is part of the Styleguide, which consists of 3 files.
#
# STEP 1: HARVESTING *** THIS FILE ***
# Crawl the app and capture all pages and states necessary to generate your Styleguide. This file sticks a bunch of .html and .png files in /doc/ux.
# 100% Coverage is a good goal, but probably not necessary, nor pragmatic.
#
# STEP 2: DECLARATION
# Declare all your UI Elements (name, page, selector). This file lives at /app/views/kss/home/styleguide2.html.erb
# Example Declaration for your UI Element named "card-completed" that comes from
# the .html file `paper_manager`
# and it looks for css to match `source-page-selector`
# then wraps it in a div with an ID or Class of `source-page-selector-context`
# <div element-name="card-completed"
#      source-page-name="paper_manager"
#      source-page-selector=".card--completed"
#      source-page-selector-context=".column">
# </div>
#
# STEP 3: HYDRATION
# This file is responsible for updating styleguide.html with HTML
# from the .html files in /docs/ux, based on the declared attributes
# This is currently `testing.rb`.
#
# STEP 4: UPDATING
# This process should be run periodically
# (every 1-2 on an active project, maybe more)


require 'spec_helper'

describe "update the Styleguide", js: true, selenium: true do

  let(:admin) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create(:journal) }
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let!(:flow) do
    create :flow, title: "Up for grabs", query: { assigned: true }, role_id: nil
  end

  let!(:task) { FactoryGirl.create(:financial_disclosure_task, paper: paper) }

  before do
    admin.flows << flow
  end

  # allows a block to retrieve its description - the it "is here description" do
  let(:name) do |e|
    e.description
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "save HTML and .pngs for every page in the App" do
    scenario "dashboard" do |p|
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

    scenario "paper_manager" do
      Task.first.update(completed: true)
      visit '/papers/1/manage'
      # also include an overlay
      first(".card .card-content", visible: true)
      first(".card .card-content").click
      first(".overlay", visible: true)
      page.grab(name)
    end

    scenario "paper_manager_overlay" do
      visit '/papers/1/manage'
      # also include an overlay
      first(".card .card-content", visible: true); sleep 3 # hacky
      card = first(".card .card-content")
      card.hover
      card.find(".card-remove").click
      first(".overlay--fullscreen", visible: true)
      page.grab(name)
    end

    scenario "financial-disclosure-card" do
      visit '/papers/1/manage'
      first(".card .card-content", visible: true); sleep 3 # hacky
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
