require 'support/pages/card_overlay'
require 'support/pages/dashboard_page'

class SubmitPaperOverlay < CardOverlay
  def has_paper_title?
    has_selector? '.overlay-container h2'
  end

  def submit
    click_on 'Yes, Submit My Manuscript'
    wait_for_ajax
    DashboardPage.new
  end
end
