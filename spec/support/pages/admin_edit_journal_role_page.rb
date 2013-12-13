class AdminEditJournalRolePage < Page
  def editor?
    find('#journal_role_editor').checked?
  end

  def reviewer?
    find('#journal_role_reviewer').checked?
  end

  def cancel
    click_on 'Cancel'
    AdminJournalRolesPage.new
  end
end
