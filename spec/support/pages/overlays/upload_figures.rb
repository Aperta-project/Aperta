class UploadFiguresOverlay < CardOverlay
  def has_image? image_name
    have_xpath("//img[contains(@src, \"#{image_name}\"]")
  end

  def attach_figure
    session.execute_script "$('#figure_attachment').css('position', 'relative')"
    attach_file('figure_attachment', Rails.root.join('spec', 'fixtures', 'yeti.tiff'), visible: false)
    session.execute_script "$('#figure_attachment').css('position', 'absolute')"
  end
end
