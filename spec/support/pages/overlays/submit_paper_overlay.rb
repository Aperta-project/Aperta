class SubmitPaperOverlay < CardOverlay
  def has_paper_title?
    has_selector? '.overlay-container h2'
  end

  def submit
    click_on 'Yes, Submit My Manuscript'
    DashboardPage.new
  end
end
