class NewSubmissionPage < Page
  path :new_paper

  def create_submission short_title, journal: Journal.first.name
    fill_in 'Short title', with: short_title
    select journal, from: 'Journal'
    click_on 'Create'
    EditPaperPage.new
  end
end
