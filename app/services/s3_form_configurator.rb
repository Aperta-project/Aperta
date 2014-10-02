class S3FormConfigurator
  def self.form_json(aws_key, aws_secret, s3_params)
    s3_params[:access_key_id] = aws_key
    s3_params[:acl] ||= 'public-read'
    s3_params[:key] = s3_params[:upload_path] + SecureRandom.hex(10)

    policy = s3_policy(s3_params)
    s3_params[:policy] = Base64.strict_encode64(policy)

    signature = s3_signature(s3_params[:policy], aws_secret)
    s3_params[:signature] = Base64.strict_encode64(signature)

    s3_params.to_json
  end

  private

  def self.s3_policy(s3_params)
    key_root_path = s3_params[:upload_path].match(/^.*?\//).to_s
    {
      expiration: 30.minutes.from_now,
      conditions: [
        { bucket: s3_params[:bucket_name] },
        { acl: s3_params[:acl] },
        ["starts-with", "$key", key_root_path],
        ["eq", "$Content-Type", s3_params[:content_type]],
        { success_action_status: '201' }
      ]
    }.to_json
  end

  def self.s3_signature(policy, secret)
    OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new,
                         secret,
                         policy)
  end
end
