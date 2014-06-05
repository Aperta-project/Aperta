class DirectUploadsController < ApplicationController
  before_action :authenticate_user!

  def request_policy
    render json: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      acl: 'public-read',
      policy: s3_upload_policy_document,
      signature: s3_upload_signature,
      key: "uploads/#{current_user.id}/#{params[:file_prefix]}/#{SecureRandom.uuid}"
    }
  end

  private

  def request_params
    params.require(:file_prefix)
  end

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    Base64.encode64(
      {
        expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        conditions: [
          { bucket: ENV['S3_BUCKET'] },
          { acl: 'public-read' },
          ["starts-with", "$key", "uploads/"],
          ["eq", "$Content-Type", params[:content_type]],
          { success_action_status: '201' }
        ]
      }.to_json
    ).gsub(/\n|\r/, '')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        ENV['AWS_SECRET_ACCESS_KEY'],
        s3_upload_policy_document
      )
    ).gsub(/\n/, '')
  end
end
