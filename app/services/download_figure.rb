class DownloadFigure
  def self.call(figure, url)
    figure.attachment.download! url
    figure.title = figure.attachment.filename unless figure.title
    figure.save
    figure
  end
end
