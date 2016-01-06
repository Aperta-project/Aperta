class SupportingInfoOverlay < CardOverlay
  def has_file? file_name
    have_xpath("//a[contains(@href, \"#{file_name}\"]")
  end

  def attach_supporting_information
    session.execute_script "$('#file_attachment').css('position', 'relative')"
    attach_file('file_attachment', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false)
    session.execute_script "$('#file_attachment').css('position', 'absolute')"
  end

  def edit_file_info
    find('.si-file-edit-icon').click
  end

  def save_file_info
    find('.si-file-save-edit-button').click
  end

  def file_title_input=(new_title)
    title = find('.si-file-title-input .format-input-field')
    title.click
    title.send_keys new_title
  end

  def file_caption_input=(new_caption)
    caption = find('.si-file-caption-textbox .format-input-field')
    caption.click
    caption.send_keys new_caption
  end

  def file_label_input=(new_label)
    label = find('.si-file-label-input')
    label.set new_label
  end

  def file_category_dropdown=(new_category)
    power_select('.si-file-category-input', new_category)
  end

  def toggle_file_striking_image
    checkbox = find('.si-file-striking-image-checkbox')
    checkbox.click
  end

  def file_title
    find('.si-file-title').text
  end

  def file_caption
    find('.si-file-caption').text
  end

  def publishable_checkbox
    find(".publishable")
  end

  def upload_files
    click_button "Upload File"
  end

  def delete_file
    find('.si-file-delete-icon').click
    find('.si-file-delete-button').click
  end
end
