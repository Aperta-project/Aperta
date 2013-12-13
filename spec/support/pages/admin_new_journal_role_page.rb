class AdminNewJournalRolePage < Page
  def user= full_name
    within('#journal_role_user_id_field') do
      find('label.ui-button').click
    end

    within(".ui-autocomplete") do
      all('a').detect { |a| a.text == full_name }.click
    end
  end

  def journal= journal_name
    within('#journal_role_journal_id_field') do
      find('label.ui-button').click
    end

    within(".ui-autocomplete") do
      all('a').detect { |a| a.text == journal_name }.click
    end
  end

  def set_editor
    check 'Editor'
  end

  def set_reviewer
    check 'Reviewer'
  end

  def save
    click_on 'Save'
    AdminJournalRolesPage.new
  end
end
