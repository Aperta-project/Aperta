class FinancialDisclosureOverlay < CardOverlay
  def received_funding
    find('#received-funding-yes')
  end

  def received_no_funding
    find('#received-funding-no')
  end

  def dataset
    find('.question-dataset')
  end
end
