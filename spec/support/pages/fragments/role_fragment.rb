class RoleFragment < PageFragment
  text_assertions :name, ".name-field"

  def name
    find(".name-field").text
  end

  def name=(new_name)
    fill_in "role[name]", with: new_name
  end

  def edit
    find(".name-field").click
  end

  def delete
    find('.role-delete-button').click
  end

  def save
    find(".action-buttons .button-primary").click
  end

end
