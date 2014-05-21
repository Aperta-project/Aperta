class SupportingInformationOverlay < CardOverlay
  def has_file? file_name
    have_xpath("//a[contains(@href, \"#{file_name}\"]")
  end

  def attach_file
    raise "IMPLEMENT THIS!"
    # session.execute_script "$('#figure_attachment').css('position', 'relative')"
    # attach_file('figure_attachment', Rails.root.join('spec', 'fixtures', 'yeti.tiff'), visible: false)
    # session.execute_script "$('#figure_attachment').css('position', 'absolute')"
  end

  def upload_files
    click_button "Upload File"
  end
end

