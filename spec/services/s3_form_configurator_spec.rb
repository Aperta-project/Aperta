require 'json'
class S3FormConfigurator 

  def self.form_json(url, aws_key, aws_secret, user_id, bucket_name)
    {url: url}.to_json
  end
end

describe S3FormConfigurator do

  describe "form_json" do
    let(:result) do
      post_params = {s3:
                {url: "testUrl",
                 bucket_name: "aBucket",
                 path_prefix: "aPath"}
      }

      result = S3FormConfigurator.form_json(test_url,
                                            aws_key,
                                            aws_secret,
                                            user_id,
                                            bucket_name,
                                            path_prefix)
      JSON.parse(result)
    end

    it "contains the specified url" do
      expect(result["url"]).to eq("foo")
    end

    it "has the aws key" do
      expect(result["access_key_id"]).to eq("key")
    end

    it "specifies the acl as 'public read'" do
      expect(result["acl"]).to eq("public-read")
    end

    it "contains a policy key whose value is base64 encoded object"
    it "contains a signature whose value is base64 encoded"

    it "has a key that segregates files by user id and file prefix"
    it "generates a random key each time"

    describe "the policy object" do
      it "has an expiration key whose value is a date-time string"
      it "has an array of conditions"
      describe "policy conditions" do
        it "contains the bucket"
        it "specifies the acl as public-read"
        it "specifies conditions on the key"
        it "specifies conditions the content type"
        it "sets the status to '201' on success"
      end
    end
  end

  # see http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
  # policy -> hmac digest -> base64
  def test_signature(signature, key, policy_64)
    Base64.decode(signature)

    reference = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),
                                     key,
                                     policy_64)

  end
end
