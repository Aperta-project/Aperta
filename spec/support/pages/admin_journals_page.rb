class AdminJournalsPage < Page
  def view_journal journal_id
    journal_row(journal_id).click_on 'Show'
    wait_for_pjax
    AdminJournalPage.new
  end

  def edit_journal journal_id
    journal_row(journal_id).click_on 'Edit'
    wait_for_pjax
    AdminEditJournalPage.new
  end

  private

  def journal_row id
    wait_for_pjax
    all('#list table tbody tr').detect do |tr|
      tr.find('.id_field').text == id.to_s
    end
  end
end
