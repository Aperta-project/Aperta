class AdminEditJournalPage < Page
  def upload_logo
    attach_file('journal_logo', Rails.root.join('spec', 'fixtures', 'yeti.jpg'))
  end

  def save
    click_on 'Save'
    AdminJournalsPage.new
  end
end
