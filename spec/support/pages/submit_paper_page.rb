class SubmitPaperPage < Page
  def initialize(element=nil)
    expect(page).to have_css('#submit-paper')
    super
  end

  %w(title abstract authors).each do |attr|
    define_method "has_paper_#{attr}?" do
      has_selector? "#paper-#{attr}"
    end
  end

  def submit
    click_on "Submit"
    DashboardPage.new
  end
end
