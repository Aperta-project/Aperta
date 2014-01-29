class NewSubmissionPage < Page
  path :new_paper

  def create_submission short_title, journal: Journal.first.name, paper_type: nil
    fill_in 'Short title', with: short_title
    select journal, from: 'Journal'
    select paper_type, from: 'Paper type' if paper_type.present?
    click_on 'Create'
    EditPaperPage.new
  end
end
