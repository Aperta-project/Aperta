class ContentNotSynchronized < StandardError; end
#
# Page Fragment can be any element in the page.
#
class PageFragment
  include RSpec::Matchers

  attr_reader :element

  delegate :select, to: :element

  class << self
    def text_assertions(name, selector, block=nil)
      define_method "has_#{name}?" do |text|
        has_css?(selector, text: block ? block.call(text) : text)
      end
      define_method "has_no_#{name}?" do |text|
        has_no_css?(selector, text: block ? block.call(text) : text)
      end
    end
  end

  def initialize(element, context: nil)
    @element = element
    @context = context
  end

  def method_missing method, *args, &block
    if element.respond_to? method
      element.send method, *args, &block
    else
      super
    end
  end

  # We could have proxied `#all` to the element,
  # but alas, RSpec hijacks it.
  def find_all(*args)
    element.all *args
  end

  def class_names
    element[:class].split(' ')
  end

  def has_class_name?(name)
    class_names.include?(name)
  end

  def session
    if Capybara::Session === element
      element
    else
      element.session
    end
  end

  def has_no_application_error?
    session.has_no_css?("#application-error")
  end

  def retry_stale_element
    yield
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    Rails.logger.warn "Rescue stale element"
    retry
  end

  def has_application_error?
    session.has_css?("#application-error")
  end

  def view_card(card_name, overlay_class=nil, &block)
    synchronize_content! card_name
    find('.card-content', text: card_name).click
    synchronize_content! 'CLOSE'

    overlay_class ||= begin
                      "#{card_name.gsub ' ', ''}Overlay".constantize
                    rescue NameError
                      CardOverlay
                    end
    overlay = overlay_class.new session.find(".overlay")
    if block_given?
      retry_stale_element do
        block.call overlay
      end
      expect(session).to have_no_css("#delayedSave", visible: false)
      expect(overlay).to have_no_application_error
      overlay.dismiss
    else
      overlay
    end
  end

  protected
  attr_reader :context

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

    def visit args = [], sync_on:nil
      page.visit Rails.application.routes.url_helpers.send @_path, *args
      page.synchronize_content! sync_on if sync_on
      new
    end
  end

  def initialize(element = nil, context: nil)
    super(element || page, context: context)
  end

  def reload sync_on:nil
    visit page.current_path
    synchronize_content! sync_on if sync_on
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

  def sign_out
    find('.navigation-toggle').click
    find('a.navigation-item', text: 'SIGN OUT').click
  end
end
