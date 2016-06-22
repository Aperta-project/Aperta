class DownloadFigureWorker
  include Sidekiq::Worker

  def figure_regex
    /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
  end

  def perform(figure_id, url)
    figure = Figure.find figure_id
    figure.download! url
  end
end
