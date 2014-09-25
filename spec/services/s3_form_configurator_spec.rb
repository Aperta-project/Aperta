require 'json'
class S3FormConfigurator 

  def self.form_json(aws_key, aws_secret, s3_params)
    {url: s3_params[:url],
     key: s3_params[:upload_path],
     acl: "public-read"}.to_json
  end
end

# To post to s3 from a web form we need to give the client some information via a JSON payload.
# here's how it should look:
# {url: <s3-url>
#  access_key_id: <our-aws-access-key-id>
#  acl: 'public-read' // the permissions that this file will have
#  policy: <s3-policy> // this is a Base64 encoded JSON object with newlines and carriage returns removed.
#  signature: <s3-signature> // this is a Base64 encoded HMAC digest generated using our aws key and the <s3-policy>
#  key: 'some/directory/path/<some-unique-id>' // this is where the file will go inside the bucket.  It should have a uuid or something as its directory.
#  }
#
# The s3 policy should look as follows before it's Base64 encoded:
# {expiration: <ISO8601-time-stamp>, //expiration should probably be 30 minutes from the current time.
# conditions: [
#   { bucket: <s3-bucket-name> },
#   { acl: 'public-read' },
#   ["starts-with", "$key", "<key-root-path>"], //in the example shown here, this would be 'some/'
#   ["eq", "$Content-Type", <content-type>],
#   { success_action_status: '201' }
# }
# After base64 encoding the s3 policy should have newlines and carriage returns removed.
#
# The s3 signature can be created using OpenSSL::HMAC.digest.  The signature should take the aws secret key
# as as its key, and the previously created policy document (already Base64 encoded and gsubbed) as its data
# Use an OpenSSl sha1 digest as the digest for the key.
#
# You'll need to make some kind of service class (that'd be the easiest) that can spit out the aforementioned JSON object given a set of params.
#
describe S3FormConfigurator do

  describe "form_json" do
    let(:default_s3_params) do
        {url: "testUrl",
         bucket_name: "aBucket",
         upload_root: "pending",
         upload_path: "files/pictures",
         content_type: "jpeg"}
    end
    let(:result) do
      aws_key = "foo"
      aws_secret = "bar"
        result = S3FormConfigurator.form_json(aws_key,
                                              aws_secret,
                                              default_s3_params
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

    it "generates a key that starts with the specified upload_path." do
      key = JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params))["key"]
      expect(key).to match(/^files\/pictures/)
    end

    it "generates a key that is a combination of the specified upload path and a random token" do
      key1 = JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params))["key"]
      key2 = JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params))["key"]

      expect(key1).to_not eq(key2)
    end

    describe "the policy object" do
      it "has an expiration key whose value is a date-time string"
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
