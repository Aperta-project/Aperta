module S3
  class RequestPoliciesController < ApplicationController
    before_action :authenticate_user!

    def show
      render json: {
        url: upload_form.url,
        access_key_id: upload_form.access_key_id,
        acl: upload_form.acl,
        policy: upload_form.policy,
        signature: upload_form.signature,
        key: upload_form.key
      }
    end

    # rubocop:disable Metrics/AbcSize
    def sign
      render json: {  url: upload_form.url,
                      formData: {
                        acl: upload_form.acl,
                        awsaccesskeyid: upload_form.access_key_id,
                        key: "#{upload_form.key}/#{params[:file_name]}",
                        policy: upload_form.policy,
                        signature: upload_form.signature,
                        success_action_status: '201',
                        'Content-Type' => params[:content_type] }
                    }
    end

    private

    def upload_form
      S3FormConfigurator.new(
        url: ENV['S3_URL'],
        bucket_name: ENV['S3_BUCKET'],
        aws_key: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret: ENV['AWS_SECRET_ACCESS_KEY'],
        upload_path: "pending/#{current_user.id}/#{params[:file_prefix]}",
        content_type: params[:content_type])
    end
  end
end
