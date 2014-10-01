require 'json'
require 'base64'
require 'pry'

class S3FormConfigurator

  def self.form_json(aws_key, aws_secret, s3_params)
    policy64 = encoded_policy(s3_params)
    {
      url: s3_params[:url],
      key: s3_params[:upload_path],
      access_key_id: aws_key,
      acl: "public-read",
      policy: policy64,
      signature: signature(aws_secret, policy64)
    }.to_json
  end

  private

  def self.signature(secret, policy)
   digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'),
                                   secret,
                                   policy)

   Base64.encode64(digest).gsub(/\n|\r/, '')
  end

  def self.encoded_policy(s3_params)
    Base64.encode64({expiration: DateTime.now.to_s,
                     conditions:
                     [
                       {bucket: s3_params[:bucket_name]},
                       {acl: "public-read"},
                       ["eq", "$Content-Type", s3_params[:content_type]],
                       ["starts-with", "$key", "files"],
                       {success_action_status: '201'}
                     ]
                    }.to_json
                   ).gsub(/\n|\r/, '')
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
# as as its key, and the previously created policy document (already Base64 encoded and gsubbed to remove \n and \r) as its data
# Use an OpenSSl sha1 digest as the digest for the key. After that the signature itself should be base64 encoded.
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
      expect(result["access_key_id"]).to eq("foo")
    end

    it "specifies the acl as 'public read'" do
      expect(result["acl"]).to eq("public-read")
    end

    it "generates a key that starts with the specified upload_path." do
      s3_params = default_s3_params.merge({upload_path: "files/pictures/"})
      key = JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params))["key"]
      expect(key).to match(/^files\/pictures/)

      s3_params = s3_params.merge({upload_path: "some/path/"})
      key = JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params))["key"]
      expect(key).to match(/^some\/path/)
    end

    it "generates a key that is a combination of the specified upload path and a random token" do
      key1 = JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params))["key"]
      key2 = JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params))["key"]

      expect(key1).to_not eq(key2)
    end

    def extract_policy_json(overall_result)
      JSON.parse(Base64.decode64(overall_result["policy"]))
    end

    describe "the policy object" do

      it "shouldn't have any newlines or carriage returns after base64 encoding" do
        policy_string = result["policy"]
        expect(policy_string).not_to match(/\n|\r/)
      end

      it "has an expiration key whose value is a date-time string" do
        policy = extract_policy_json(result)
        expect(DateTime.iso8601(policy["expiration"])).to_not be_nil
      end

# conditions: [
#   { bucket: <s3-bucket-name> },
#   { acl: 'public-read' },
#   ["starts-with", "$key", "<key-root-path>"], //in the example shown here, this would be 'some/'
#   ["eq", "$Content-Type", <content-type>],
#   { success_action_status: '201' }
# }
      describe "policy conditions" do
        it "contains the bucket" do
          s3_params = default_s3_params.merge({bucket_name: "Bucket"})
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params)))
          expect(policy_json["conditions"]).to include({"bucket" => "Bucket"})
        end
        it "specifies the acl as public-read" do
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params)))
          expect(policy_json["conditions"]).to include({"acl" => "public-read"})
        end
        it "specifies that the key should start with the root of the specified upload path" do
          s3_params = default_s3_params.merge({upload_path: "some/path/"})
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params)))
          expect(policy_json["conditions"]).to include(["starts-with", "$key", "some/"])

          s3_params = default_s3_params.merge({upload_path: "another/path/"})
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params)))
          expect(policy_json["conditions"]).to include(["starts-with", "$key", "another/"])
        end

        it "specifies conditions the content type" do
          s3_params = default_s3_params.merge({content_type: "jpeg"})
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params)))
          expect(policy_json["conditions"]).to include(["eq", "$Content-Type", "jpeg"])

          s3_params = default_s3_params.merge({content_type: "gif"})
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", s3_params)))
          expect(policy_json["conditions"]).to include(["eq", "$Content-Type", "gif"])
        end

        it "specifies success_action_status to be '201'" do
          policy_json = extract_policy_json(JSON.parse(S3FormConfigurator.form_json("foo", "bar", default_s3_params)))
          expect(policy_json["conditions"]).to include({'success_action_status' => '201'})
        end
      end
    end

    # see http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
    describe "the signature" do

      it "The signature should use the policy and s3 secret to create a bas64 encoded digest" do
           result = JSON.parse(S3FormConfigurator.form_json("foo", "s3_secret", default_s3_params))
           reference = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'),
                                           "s3_secret",
                                           result["policy"])
           encoded_reference = Base64.encode64(reference).gsub(/\n|\r/, '')

           expect(result["signature"]).to eq(encoded_reference)
      end
    end
  end
end
