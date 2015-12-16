class AdminJournalsPage < Page
  def view_journal journal_id
    journal_row(journal_id).click_on 'Show'
    session.has_content? 'Details for Journal'
    AdminJournalPage.new
  end

  def edit_journal journal_id
    journal_row(journal_id).click_on 'Edit'
    session.has_content? 'Edit Journal'
    AdminEditJournalPage.new
  end

  private

  def journal_row id
    session.has_content? id.to_s
    all('#list table tbody tr').detect do |tr|
      tr.find('.id_field').text == id.to_s
    end
  end
end
