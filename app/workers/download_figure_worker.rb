class DownloadFigureWorker
  include Sidekiq::Worker

  def figure_regex
    /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
  end

  def perform(figure_id, url)
    figure = Figure.find figure_id
    figure.attachment.download! url
    unless figure.title
      figure.title = "Unlabeled"
      figure_regex.match(figure.attachment.filename) do |match|
        figure.title = "Fig. #{match['label']}"
      end
    end
    figure.status = "done"
    figure.save
    figure
  end
end
