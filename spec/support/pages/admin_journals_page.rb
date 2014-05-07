class AdminJournalsPage < Page
  def view_journal journal_id
    journal_row(journal_id).click_on 'Show'
    synchronize_content!("Details for Journal")
    AdminJournalPage.new
  end

  def edit_journal journal_id
    journal_row(journal_id).click_on 'Edit'
    synchronize_content!("Edit Journal")
    AdminEditJournalPage.new
  end

  private

  def journal_row id
    synchronize_content! id.to_s
    all('#list table tbody tr').detect do |tr|
      tr.find('.id_field').text == id.to_s
    end
  end
end
