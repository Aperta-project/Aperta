class ContentNotSynchronized < StandardError; end
#
# Page Fragment can be any element in the page.
#
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

  def class_names
    @element[:class].split(' ')
  end

  def has_class_name?(name)
    class_names.include?(name)
  end

  def session
    if Capybara::Session === @element
      @element
    else
      @element.session
    end
  end

  def view_card card_name, overlay_class=nil, &block
    synchronize_content! card_name
    session.all('.card-content', text: card_name).first.click
    synchronize_content! 'CLOSE'

    overlay_class ||= begin
                      "#{card_name.gsub ' ', ''}Overlay".constantize
                    rescue NameError
                      CardOverlay
                    end
    overlay = overlay_class.new session.find(".overlay")
    if block_given?
      block.call overlay
      overlay.dismiss
    else
      overlay
    end
  end

  protected

  def select_from_chosen(item_text, options={})
    session.execute_script(%Q!$(".#{options[:class]}.chosen-container:first").mousedown()!)
    find(".#{options[:class]}.chosen-container input[type=text]").set(item_text)
    session.execute_script(%Q!$(".#{options[:class]}.chosen-container:first input").trigger(jQuery.Event("keyup", { keyCode: 13 }))!)
    synchronize_content!(item_text) unless options[:skip_synchronize]
  end

  private

  def synchronize_content! content
    unless (session.has_content?(content) ||
            session.has_content?(content.upcase) ||
            session.has_content?(content.downcase))
      raise ContentNotSynchronized.new("Page has no content #{content}")
    end
  end

  def synchronize_no_content! content
    unless (session.has_no_content?(content) ||
            session.has_no_content?(content.upcase) ||
            session.has_no_content?(content.downcase))
      raise ContentNotSynchronized.new("Page expected to not have content \"#{content}\", but it does")
    end
  end
end

#
# Page expects a path and asserts against it. Uses Rails routing helpers to accomplish this.
#
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
  end

  def reload
    visit page.current_path
  end

  def notice
    find('p.notice').text
  end

  def navigate_to_dashboard
    within('.nav-bar') do
      click_on 'Dashboard'
      DashboardPage.new
    end
  end
end
