module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests? && finished_ember_requests?
    end
  end

  def finished_all_ajax_requests?(session=Capybara.current_session)
    session.evaluate_script('jQuery.active').zero?
  end

  def finished_ember_requests?(session=Capybara.current_session)
    session.evaluate_script("!Ember.run.hasScheduledTimers() && !Ember.run.currentRunLoop")
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
