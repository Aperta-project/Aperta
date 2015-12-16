class AdminJournalRolesPage < Page
  def add_role
    click_on 'Add new'
    AdminNewJournalRolePage.new
  end

  def edit_role full_name, journal_name
    role_row = all('#list table tbody tr').detect do |tr|
      tr.find('.user_field').text == full_name &&
        tr.find('.journal_field').text == journal_name
    end
    role_row.click_on 'Edit'
    session.has_content? 'Edit Journal'
    AdminEditJournalRolePage.new
  end
end
