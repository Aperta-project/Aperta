require 'json'
class S3FormConfigurator 

  def self.form_json(url, aws_key, aws_secret, user_id, bucket_name)
    {url: url}.to_json
  end
end

# To post to s3 from a web form we need to give the client some information via a JSON payload.
# here's how it should look:
# {url: <s3-url>
#  access_key_id: <our-aws-access-key-id>
#  acl: 'public-read' // the permissions that this file will have
#  policy: <s3-policy> // this is a Base64 encoded JSON object with newlines and carriage returns removed.
#  signature: <s3-signature> // this is a Base64 encoded HMAC digest generated using our aws key and the <s3-policy>
#  key: 'some/directory/path' // this is where the file will go inside the bucket.  It should be unique.
#  }
#
# The s3 policy should look as follows before it's Base64 encoded:
# {expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
# conditions: [
#   { bucket: <s3-bucket-name> },
#   { acl: 'public-read' },
#   ["starts-with", "$key", "<key-root-path>"], //in the example shown here, this would be 'some/'
#   ["eq", "$Content-Type", <content-type>],
#   { success_action_status: '201' }
# }
describe S3FormConfigurator do

  describe "form_json" do
    let(:result) do
      s3_params =
         {url: "testUrl",
          bucket_name: "aBucket",
          upload_root: "pending",
          upload_path: "files/pictures",
          content_type: "jpeg"}

      result = S3FormConfigurator.form_json(aws_key,
                                            aws_secret,
                                            s3_params
                                           )
      JSON.parse(result)
    end

    it "contains the specified url" do
      expect(result["url"]).to eq("testUrl")
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
