class DirectUploadsController < ApplicationController
  before_action :authenticate_user!

  def request_policy
    render json: {
      policy: s3_upload_policy_document,
      signature: s3_upload_signature,
      key: "uploads/user/avatar/#{current_user.id}",
      success_action_redirect: profile_path
    }
  end

  def file_url
    # some carrierwave processing method
    current_user.avatar.download! params[:url]
    current_user.save!
    head :ok
  end

  private

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    Base64.encode64(
      {
        expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        conditions: [
          { bucket: ENV['S3_BUCKET'] },
          { acl: 'public-read' },
          ["starts-with", "$key", "uploads/"],
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
