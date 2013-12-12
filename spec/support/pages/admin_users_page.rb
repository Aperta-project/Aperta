class AdminUsersPage < Page
  def edit_user user_id
    wait_for_pjax
    user_row = all('#list table tbody tr').detect do |tr|
      tr.find('.id_field').text == user_id.to_s
    end
    user_row.click_on 'Edit'
    wait_for_pjax
    AdminEditUserPage.new
  end
end
