require 'support/sidekiq_helper_methods'
require 'support/wait_for_ajax'

class ContentNotSynchronized < StandardError; end
#
# Page Fragment can be any element in the page.
#
class PageFragment
  include RSpec::Matchers
  include SidekiqHelperMethods
  extend WaitForAjax
  include WaitForAjax

  attr_reader :element

  delegate :select, to: :element

  class << self
    def text_assertions(name, selector, block=nil)
      define_method "has_#{name}?" do |text|
        retry_stale_element do
          has_css?(selector, text: block ? block.call(text) : text)
        end
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
    find('.card-content', text: card_name).click

    overlay_class ||= begin
                      "#{card_name.gsub ' ', ''}Overlay".constantize
                    rescue NameError
                      CardOverlay
                    end
    overlay = overlay_class.new session.find(".overlay")
    if block_given?
      retry_stale_element do
        block.call overlay
        wait_for_ajax
      end
      expect(session).to have_no_css("#delayedSave", visible: false)
      expect(overlay).to have_no_application_error
      overlay.dismiss
    else
      overlay
    end
  end

  # wait_for_attachment_to_upload exists because feature specs run multiple
  # threads: a thread for running tests and another for running the app for
  # selenium, etc. Not knowing the order of execution between the threads
  # this is for providing ample time and opportunity for an Attachment
  # to be uploaded and created before moving on in a test.
  def wait_for_attachment_to_upload(sentinel, seconds=10, &blk)
    Timeout.timeout(seconds) do
      original = sentinel.call
      yield
      loop do
        break if original != sentinel.call
        sleep 0.25
      end
    end
  end

  def upload_file(element_id:, file_name:, sentinel:)
    file_path = Rails.root.join('spec', 'fixtures', file_name)
    wait_for_attachment_to_upload(sentinel) do
      attach_file element_id, file_path, visible: false
    end
    process_sidekiq_jobs
  end

  attr_reader :context

  def power_select(cssPath, value)
    find("#{cssPath} .ember-power-select-trigger").click
    find(".ember-power-select-option", text: value).click
  end

  def select2(value, options = {})
    raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }

    if options.has_key? :xpath
      select2_container = first(:xpath, options[:xpath])
    elsif options.has_key? :css
      select2_container = first(:css, options[:css])
    else
      select_name = options[:from]
      select2_container = find("label", text: select_name).find(:xpath, '..').find(".select2-container")
    end

    drop_container = ".select2-drop"
    drop_specifier = "li.select2-result-selectable"
    # Open select2 field
    if select2_container.has_selector?(".select-box-element")
      select2_container.find(".select-box-element").click
      drop_container = ".select-box-item"
      drop_specifier = ""
    elsif select2_container.has_selector?(".select2-choice")
      select2_container.find(".select2-choice").click
    else
      select2_container.find(".select2-choices").click
    end

    if options.has_key? :search
      find(:xpath, "//body").find(".select2-with-searchbox input.select2-input").set(value)
      page.execute_script(%|$("input.select2-input:visible").keyup();|)
      drop_container = ".select2-results"
    end

    [value].flatten.each do |value|
      find(:xpath, "//body").find("#{drop_container} #{drop_specifier}", text: value).click
    end
  end


  private

  def synchronize_no_content!(content)
    unless session.has_no_content?(Regexp.new(Regexp.escape(content), Regexp::IGNORECASE))
      fail ContentNotSynchronized, "Page expected to not have content \"#{content}\", but it does"
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
      page.has_content? sync_on if sync_on
      new
    end

    def view_task_overlay(paper, task)
      new.view_task_overlay(paper, task)
    end
  end

  def initialize(element = nil, context: nil)
    super(element || page, context: context)
  end

  def reload sync_on:nil
    visit page.current_path
    page.has_content? sync_on if sync_on
  end

  def notice
    find('p.notice')
  end

  def navigate_to_dashboard
    find('.main-nav-item-app-name').click
    DashboardPage.new
  end

  def view_task_overlay(paper, task)
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    overlay_class ||= begin
                      (task.title.split(' ')
                                .map {|w| w.capitalize }
                                .join(' ').gsub(' ', '') + "Overlay")
                                .constantize
                    rescue NameError
                      CardOverlay
                    end
    overlay_class.new session.find(".overlay")
  end

  def sign_out
    find('#profile-dropdown-menu').click
    find('.main-nav a', text: 'Sign Out').click

    within ".auth-container" do
      find(".auth-flash", text: "Signed out successfully.")
    end
  end
end
