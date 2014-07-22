class DownloadFigureWorker
  include Sidekiq::Worker

  def perform(figure_id, url)
    figure = Figure.find figure_id
    figure.attachment.download! url
    figure.title = figure.attachment.filename unless figure.title
    figure.status = "done"
    figure.save
    figure
  end
end
