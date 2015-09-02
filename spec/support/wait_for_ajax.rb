module WaitForAjax
  def wait_for_ajax
    loop until finished_all_ajax_requests?
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
