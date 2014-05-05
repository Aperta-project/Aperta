class AdminUsersPage < Page
  def edit_user user_id
    expect(page).to have_css('.user_row td.id_field', text: user_id.to_s)
    user_row = all('#list table tbody tr').detect do |tr|
      tr.find('.id_field').text == user_id.to_s
    end
    user_row.click_on 'Edit'
    AdminEditUserPage.new
  end
end
