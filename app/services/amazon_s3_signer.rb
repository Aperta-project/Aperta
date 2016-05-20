# This Service class help us to generate the appropiate params required
# for a direct upload to Amazon S3
class AmazonS3Signer
  def initialize(file_name:, file_path:, content_type:)
    @file_name = file_name
    @file_path = file_path
    @content_type = content_type
    @expires = 1.day.from_now
  end

  def params # rubocop:disable Metrics/MethodLength
    {
      acl: 'public-read',
      awsaccesskeyid: ENV['AWS_ACCESS_KEY_ID'],
      bucket: ENV['S3_BUCKET'],
      expires: @expires,
      key: "#{@file_path}/#{@file_name}",
      policy: policy,
      signature: signature,
      success_action_status: '201',
      'Content-Type' => @content_type,
      'Cache-Control' => 'max-age=630720000, public'
    }
  end

  private

  def signature
    Base64.strict_encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        ENV['AWS_SECRET_ACCESS_KEY'],
        policy
      )
    )
  end

  def policy # rubocop:disable Metrics/MethodLength
    Base64.strict_encode64(
      {
        expiration: @expires,
        conditions: [
          { bucket: ENV['S3_BUCKET'] },
          { acl: 'public-read' },
          { expires: @expires },
          { success_action_status: '201' },
          ['starts-with', '$key', ''],
          ['starts-with', '$Content-Type', ''],
          ['starts-with', '$Cache-Control', ''],
          ['content-length-range', 0, 524_288_000]
        ]
      }.to_json
    )
  end
end
