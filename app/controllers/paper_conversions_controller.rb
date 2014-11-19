class PaperConversionsController < ApplicationController
  def export
    @paper = Paper.find(params[:id])
    @export_format = params[:format]
    response = PaperConverterWorker.export(@paper, @export_format, current_user)
    render json: JSON.parse(response), status: 203
  end

  def status
    job = PaperConverterWorker.check_status(params[:id])
    render json: JSON.parse(job)
  end

  # def export_download
  #   # we're assuming that at this point the converted file has already been
  #   # downloaded by Tahi and associated to a paper. It's available in Tahi's S3
  #   # bucket
  #   paper = Paper.find(params[:id])
  #   render json: { converted_file_url: paper.converted_file_url }
  # end
end
