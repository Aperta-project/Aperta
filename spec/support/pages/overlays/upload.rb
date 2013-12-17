class UploadOverlay < CardOverlay
  def has_image? image_name
    has_selector? "img[src$='#{image_name}']"
  end

  def attach_figure
    session.execute_script "$('#figure_attachment').css('position', 'relative')"
    attach_file('figure_attachment', Rails.root.join('spec', 'fixtures', 'yeti.tiff'), visible: false)
    session.execute_script "$('#figure_attachment').css('position', 'absolute')"
  end

  def upload_figures
    click_button "Upload Figure"
  end
end
