class DownloadFigureWorker
  include Sidekiq::Worker

  def figure_regex
    /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
  end

  def perform(figure_id, url)
    figure = Figure.find figure_id
    figure.attachment.download! url
    figure.create_title_from_filename
    figure.status = "done"
    figure.save
    figure
  end
end
