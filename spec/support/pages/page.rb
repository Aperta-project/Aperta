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

  def session
    if Capybara::Session === @element
      @element
    else
      @element.session
    end
  end

  def view_card card_name, &block
    click_on card_name
    overlay_class = begin
                      "#{card_name.gsub ' ', ''}Overlay".constantize
                    rescue NameError
                      CardOverlay
                    end
    overlay = overlay_class.new session.find("#overlay")
    if block_given?
      block.call overlay
      overlay.dismiss
      wait_for_turbolinks
    else
      overlay
    end
  end

  protected

  def select_from_chosen(item_text, options)
    field = if Capybara::Node::Element === options[:from]
              options[:from]
            elsif options.has_key? :from
              find_field(options[:from], visible: false)
            elsif options.has_key? :id
              find("##{options[:id]}", visible: false)
            end

    session.execute_script(%Q!$("##{field[:id]}_chosen").mousedown()!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").val("#{item_text}")!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").keyup()!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").trigger(jQuery.Event("keyup", { keyCode: 13 }))!)
  end

  def wait_for_pjax
    sleep 0.1
  end

  def wait_for_turbolinks
    sleep 0.3
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

  def initialize element = nil
    super element
    expect(current_path).to match self.class._path_regex unless self.class._path_regex.nil?
  end

  def reload
    visit page.current_path
    wait_for_turbolinks
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
end
