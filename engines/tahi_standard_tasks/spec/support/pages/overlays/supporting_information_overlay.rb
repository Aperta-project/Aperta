class SupportingInfoOverlay < CardOverlay
  def has_file? file_name
    have_xpath("//a[contains(@href, \"#{file_name}\"]")
  end

  def attach_supporting_information
    upload_file(
      element_id: 'file_attachment',
      file_name: 'yeti.jpg',
      sentinel: -> { SupportingInformationFile.count }
    )
  end

  def attach_bad_supporting_information
    upload_file(
      element_id: 'file_attachment',
      file_name: 'bad_yeti.tiff',
      sentinel: -> { SupportingInformationFile.count }
    )
  end

  def edit_file_info
    find('.si-file-edit-icon').click
  end

  def save_file_info
    find('.si-file-save-edit-button').click
  end

  def file_label_input=(new_label)
    label = find('.si-file-label-field')
    label.set new_label
  end

  def file_category_dropdown=(new_category)
    power_select('.si-file-category-input', new_category)
  end

  def toggle_file_striking_image
    checkbox = find('.si-file-striking-image-checkbox')
    checkbox.click
  end

  def toggle_for_publication
    checkbox = find('.si-file-publishable-checkbox')
    checkbox.click
  end

  def error_message
    find('.si-file-actions .error-message').text
  end

  def file_error_message
    find('.si-file-error .error-message').text
  end

  def dismiss_file_error
    find('.si-file-error .acknowledge-error-button').click
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
