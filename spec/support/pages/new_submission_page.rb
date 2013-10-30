class NewSubmissionPage < Page

  def create_submission short_title
    fill_in 'Short title', with: short_title
    click_on 'Create'
    EditSubmissionPage.new
  end
end
