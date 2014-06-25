class FinancialDisclosureOverlay < CardOverlay
  def received_funding
    find('label', text: "Yes").find('input[type=radio]')
  end

  def received_no_funding
    find('label', text: "No").find('input[type=radio]')
  end

  def dataset
    find('.dataset')
  end
end
