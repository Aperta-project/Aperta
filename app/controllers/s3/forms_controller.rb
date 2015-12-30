module S3
  # This controller helps the s3-file-uploader component
  # to get the right params to make the request to Amazon S3
  class FormsController < ApplicationController
    before_action :authenticate_user!

    def sign
      render json: { url: ENV['S3_URL'], formData: signer.params }, status: :ok
    end

    private

    def signer
      AmazonS3Signer.new(file_name: params[:file_name],
                         file_path: upload_path,
                         content_type: params[:content_type])
    end

    def upload_path
      "pending/#{current_user.id}/#{params[:file_path]}#{SecureRandom.hex(10)}"
    end
  end
end
