# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class Capybara::Session
  def wait_for_ajax(timeout: Capybara.default_max_wait_time)
    return unless jquery_and_ember_present?

    Timeout.timeout(timeout) do
      loop until finished_all_ajax_requests? && finished_ember_requests?
    end
  end

  private

  def jquery_and_ember_present?
    evaluate_script('jQuery().jquery')
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
