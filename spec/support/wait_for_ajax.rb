class Capybara::Session
  old_visit = instance_method(:visit)

  define_method(:visit_without_waiting) do |url|
    old_visit.bind(self).call(url)
  end

  define_method(:visit) do |url|
    visit_without_waiting url
    wait_for_ajax
  end

  def wait_for_ajax(timeout: Capybara.default_max_wait_time)
    return unless jquery_and_ember_present?

    Timeout.timeout(timeout) do
      loop until finished_all_ajax_requests? && finished_ember_requests?
    end
  end

  private

  def jquery_and_ember_present?
    evaluate_script('jQuery')
    evaluate_script('Ember.VERSION')
    return true
  rescue Selenium::WebDriver::Error::JavascriptError,
         Capybara::NotSupportedByDriverError
    return false
  end

  def finished_all_ajax_requests?
    evaluate_script('jQuery.active').zero?
  end

  def finished_ember_requests?
    evaluate_script("!Ember.run.hasScheduledTimers() && !Ember.run.currentRunLoop")
  end
end

module WaitForAjax
  def wait_for_ajax(session = Capybara.current_session, **opts)
    session.wait_for_ajax **opts
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
