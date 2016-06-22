class DownloadFigureWorker
  include Sidekiq::Worker

  def perform(figure_id, url)
    figure = Figure.find figure_id
    figure.download! url
  end
end
