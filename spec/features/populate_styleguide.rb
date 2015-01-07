require 'spec_helper'

describe "update the Styleguide", js: true, selenium: true do

  let(:admin) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create(:journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
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
  end

  # scenario "" do
  # end
  #
  # scenario "" do
  # end
  #
  # scenario "" do
  # end
  #
  # scenario "" do
  # end
  #
  # scenario "" do
  # end
  #
  # scenario "" do
  # end

end

# class Capybara::ElementNotFound
#   def initialize(opts)
#     binding.pry
#     super(opts)
#   end
# end

class Capybara::Session
  def grab(filename, selector = "")
    # TODO: refactor: move this
    dirname = "docs/ux"
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
