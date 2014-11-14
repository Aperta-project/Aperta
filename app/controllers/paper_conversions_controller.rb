class PaperConversionsController < ApplicationController
  def export
    paper = Paper.find(params[:id])
    export_format = params[:export_format]
    job_id = PaperConverterWorker.export(paper, export_format, current_user)
    render json: { job_id: job_id }, status: 203
  end

# def export
#   # epub = EpubConverter.new paper, current_user
#   # send_to_ihat
#
#   job_id = PaperConverterWorker.export(paper, export_format)
#
#   render json: { job_id: job_id }
# end

# def export_check
#   job_id = params[:job_id]
#   status = PaperConverterWorker.find(job_id).status
#   render json: { job_status: status }
# end

# def export_download
#   # we're assuming that at this point the converted file has already been
#   # downloaded by Tahi and associated to a paper. It's available in Tahi's S3
#   # bucket
#   paper = Paper.find(params[:id])
#   render json: { converted_file_url: paper.converted_file_url }
# end
end
