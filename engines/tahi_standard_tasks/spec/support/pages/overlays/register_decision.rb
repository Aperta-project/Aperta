class RegisterDecisionOverlay < CardOverlay
  def previous_decisions
    all('.previous-decisions .decision').map { |decision_div|
      DecisionComponent.new(decision_div)
    }
  end

  def register_decision=(decision)
    choose decision
  end

  def decision_letter=(body)
    synchronize_content!("Accepted")
    find('.decision-letter-field').set(body)
  end

  def decision_letter
    find('.decision-letter-field').get()
  end

  def radio_selected?
    all('input[type=radio]').any?(&:checked?)
  end

  def accepted?
    find('input[value="accepted"]')
  end

  def disabled?
    all("input[type='radio'][disabled]").size == 3 &&
    find("textarea[disabled]") != nil
  end

  def click_send_email_button
    find(".send-email-action").click
    # and wait for the flash message to show
    find(".alert")
  end

  def success_state_message
    find(".alert-info").text == "A final decision of accepted has been registered."
  end

  def invalid_state_message
    !find(".alert-warning").nil?
  end
end

class DecisionComponent
  attr_reader :el

  def initialize(el)
    @el = el
  end

  def revision_number
    el.find('.revision-number').text
  end

  def letter
    el.find('.letter').text
  end
end
