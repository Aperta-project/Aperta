class RoleFragment < PageFragment

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
    find('.name-field').hover
    find('.delete-button').click
  end

  def save
    find(".action-buttons .primary-button").click
  end

  def cancel

  end
end
