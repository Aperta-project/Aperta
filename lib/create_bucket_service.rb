
# rubocop:disable Rails/Output
class CreateBucketService
  PREFIX = 'tahi-user-dev'

  def initialize(name: nil)
    Aws.config.update(
      region: 'us-west-1' # northern california
    )
    @name = name
  end

  def call
    create_bucket
    create_user
    create_policy
    create_access_keys
    print_access_keys
    print_bucket_name
  end

  private

  def name
    @name ||= "#{PREFIX}-#{SecureRandom.uuid}"
  end

  def create_bucket
    @bucket = Aws::S3::Bucket.new(name).tap(&:create)
  end

  def create_user
    @user = Aws::IAM::User.new(name).tap(&:create)
  end

  def create_policy
    @user.create_policy(
      policy_name: name,
      policy_document: policy_document
    )
  end

  def create_access_keys
    @key_pair = @user.create_access_key_pair
  end

  def print_access_keys
    puts "AWS_ACCESS_KEY_ID=#{@key_pair.access_key_id}"
    puts "AWS_SECRET_ACCESS_KEY=#{@key_pair.secret}"
  end

  def print_bucket_name
    puts "S3_BUCKET=#{name}"
  end

  def policy_document
    {
      Version: "2012-10-17",
      Statement: [
        {
          Sid: "Stmt1471647590001",
          Effect: "Allow",
          Action: [
            "s3:*"
          ],
          Resource: [
            "arn:aws:s3:::#{name}",
            "arn:aws:s3:::#{name}/*"
          ]
        }
      ]
    }.to_json
  end
end
