class NewSubmissionPage < Page
  def create_submission short_title, journal: Journal.first.name
    fill_in 'paper-short-title', with: short_title
    select_from_chosen journal, class: "paper-new-journal-select"
    click_on 'Create'
    expect(session).to have_css('#paper-title')
    EditPaperPage.new
  end
end
