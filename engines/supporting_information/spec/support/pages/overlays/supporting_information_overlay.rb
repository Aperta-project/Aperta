class SupportingInformationOverlay < CardOverlay
  def has_file? file_name
    have_xpath("//a[contains(@href, \"#{file_name}\"]")
  end

  def attach_supporting_information
    session.execute_script "$('#file_attachment').css('position', 'relative')"
    attach_file('file_attachment', Rails.root.join('spec', 'fixtures', 'yeti.tiff'), visible: false)
    session.execute_script "$('#file_attachment').css('position', 'absolute')"
  end

  def upload_files
    click_button "Upload File"
  end
end

