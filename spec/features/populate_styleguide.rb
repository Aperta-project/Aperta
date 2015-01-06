require 'spec_helper'

describe "update the Styleguide", js: true, selenium: true do

  let(:author) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let(:name) do |e|
    e.description
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "dashboard" do |p|
    page.save_html(name)
  end

  scenario "navigation" do
    find(".navigation-toggle").click
    find(".navigation", visible: true)
    page.save_html(name, ".navigation")
  end

  scenario "flow_manager" do
    visit '/flow_manager'
    find(".control-bar-link", visible: true)
    page.save_screenshot("flow_manager.png")
  end

  scenario "admin" do
    visit '/admin'
    find(".journals")
    page.save_screenshot("admin.png")
  end

  scenario "" do
  end

  scenario "" do
  end

  scenario "" do
  end

  scenario "" do
  end

  scenario "" do
  end

  scenario "" do
  end

end

class Capybara::Session
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

    save_screenshot("#{filename}.png")
  end
end


# Notes

# An App has:
# * Use Cases
#     In order to meet a Use Case, a User completes a Flow
# * User Flows.
#     A User Flow is made up of screens that are designed to accomplish a Use Case.
# * Screens
#     A Screen is a complete web page (or state of a page) where a User can do something
#   Layout
#      A common html page, that might have Components too (TODO: make this more clear)
#   Component
#     Custom sets of HTML Elements, plus styling, plus .js behavior
#   Element
#     Base level HTML Markup. A single instance of <div>s and <span>s and <p>, etc.


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
