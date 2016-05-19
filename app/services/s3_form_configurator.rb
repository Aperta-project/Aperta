class S3FormConfigurator
  attr_accessor :access_key_id, :acl, :key, :policy, :signature, :url

  def initialize(s3_params, &block)
    self.acl = 'public-read'
    self.url = s3_params[:url]
    self.access_key_id = s3_params[:aws_key]

    self.key = s3_params[:upload_path] + SecureRandom.hex(10)

    self.policy = Base64.strict_encode64(s3_policy(s3_params))

    sig = s3_signature(self.policy, s3_params[:aws_secret])
    self.signature = Base64.strict_encode64(sig)

    instance_eval &block if block_given?
  end

  private

  def s3_policy(s3_params)
    key_root_path = "#{s3_params[:upload_path].split('/').first}/"
    {
      expiration: 1.day.from_now,
      conditions: [
        { bucket: s3_params[:bucket_name] },
        { acl: self.acl },
        ["starts-with", "$key", key_root_path],
        ["eq", "$Content-Type", s3_params[:content_type]],
        { success_action_status: '201' }
      ]
    }.to_json
  end

  def s3_signature(policy, secret)
    OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new,
                         secret,
                         policy)
  end
end
