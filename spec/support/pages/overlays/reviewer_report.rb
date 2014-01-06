class ReviewerReportOverlay < CardOverlay
  def report=(body)
    fill_in 'Body', with: body
  end

  def report
    find_field('Body').value
  end
end
