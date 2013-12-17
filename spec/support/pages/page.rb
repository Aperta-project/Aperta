class PageFragment
  include RSpec::Matchers

  delegate :select, to: :@element

  def initialize element = nil
    @element = element || page
  end

  def method_missing method, *args, &block
    if @element.respond_to? method
      @element.send method, *args, &block
    else
      super
    end
  end

  def view_card card_name, &block
    click_on card_name
    overlay = "#{card_name.gsub ' ', ''}Overlay".constantize.new session.find('#overlay')
    block.call overlay
    overlay.dismiss
  end
end

class Page < PageFragment
  include Capybara::DSL

  class << self
    include Capybara::DSL

    attr_reader :_path_regex

    def path path_sym
      all_routes = Rails.application.routes.routes
      inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
      route = inspector.instance_variable_get(:@routes).detect { |p| p.name == path_sym.to_s }
      @_path = "#{path_sym}_path"
      @_path_regex = ActionDispatch::Routing::RouteWrapper.new(route).json_regexp
    end

    def visit args = []
      page.visit Rails.application.routes.url_helpers.send @_path, *args
      new
    end
  end

  def initialize
    expect(current_path).to match self.class._path_regex unless self.class._path_regex.nil?
  end

  def reload
    visit page.current_path
  end

  def notice
    find('p.notice').text
  end

  def navigate_to_dashboard
    within('#nav-bar') do
      click_on 'Dashboard'
      DashboardPage.new
    end
  end

  protected

  def wait_for_pjax
    sleep 0.1
  end
end
