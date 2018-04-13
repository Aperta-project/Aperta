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

require 'support/pages/card_overlay'
require 'support/rich_text_editor_helpers'

class RegisterDecisionOverlay < CardOverlay
  include RichTextEditorHelpers

  def previous_decisions
    within(".previous-decisions") do
      all('.decision-bar').map do |decision_div|
        DecisionComponent.new(decision_div)
      end
    end
  end

  def register_decision=(decision)
    choose decision
    wait_for_ajax
  end

  def decision_letter
    get_rich_text(editor: 'decision-letter-field')
  end

  def decision_letter=(contents)
    set_rich_text(editor: 'decision-letter-field', text: contents)
  end

  def radio_selected?
    find('input[type=radio]', match: :first)
    all('input[type=radio]').any?(&:checked?)
  end

  def accepted?
    find('input[value="accepted"]')
  end

  def click_send_email_button
    find(".button-primary.button--green.send-email-action").click
    # and wait for the flash message to show
    find(".decision-bar-verdict")
  end

  def has_success_state_message?(decision: "accept")
    has_css?(".rescind-decision-container",
      text: /decision of #{decision} has been registered/i)
  end

  def invalid_state_message
    !find(".alert-warning").nil?
  end

  def rescind_button
    find(".rescind-decision-button")
  end

  def rescind_confirm_button
    find(".full-overlay-verification-confirm")
  end
end

class DecisionComponent
  attr_reader :el

  def initialize(el)
    @el = el
  end

  def revision_number
    el.find('.decision-bar-revision-number').text
  end

  def letter
    el.find('.decision-bar-letter').text
  end

  def open
    el.find('.decision-bar-bar').click
  end

  def rescinded?
    el.find('.decision-bar-rescinded') != nil
  end
end
