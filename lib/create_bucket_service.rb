
# rubocop:disable Rails/Output
class CreateBucketService
  PREFIX = 'tahi-user-dev'

  def initialize(name: nil)
    @region = 'us-west-1' # northern california
    STDOUT.write("Please enter an AWS access key of a user with permissions \
to set up a new bucket: ")
    access_key_id = STDIN.gets.chomp

    STDOUT.write("Please enter the SECRET key of the same access key: ")
    secret_access_key = STDIN.gets.chomp

    STDOUT.write("Please enter the domain that will be accessing this bucket \
(enter for wildcard *): ")
    @allowed_origins = STDIN.gets.chomp
    @allowed_origins = '*' if @allowed_origins.blank?

    Aws.config.update(
      region: @region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    )
    @name = name
  end

  def call
    create_bucket
    create_user
    create_policy
    create_access_keys
    set_cors
    print_env
  end

  private

  def name
    @name ||= "#{PREFIX}-#{SecureRandom.uuid}"
  end

  def create_bucket
    @bucket = Aws::S3::Bucket.new(name)
    @bucket.create unless @bucket.exists?
  end

  def create_user
    @user = Aws::IAM::User.new(name)
    @user.create unless @user.exists?
  end

  def create_policy
    Aws::IAM::Client.new.put_user_policy(
      user_name: @user.name,
      policy_name: name,
      policy_document: policy_document
    )
  end

  def create_access_keys
    @key_pair = @user.create_access_key_pair
  end

  def set_cors
    Aws::S3::BucketCors.new(@name).put(
      cors_configuration: {
        cors_rules: [
          {
            allowed_headers: ["*"],
            allowed_origins: [@allowed_origins],
            allowed_methods: ['PUT', 'POST'],
            max_age_seconds: 3600
          }
        ]
      }
    )
  end

  def print_env
    puts "AWS_ACCESS_KEY_ID=#{@key_pair.access_key_id}"
    puts "AWS_SECRET_ACCESS_KEY=#{@key_pair.secret}"
    puts "AWS_REGION=#{@region}"
    puts "S3_BUCKET=#{@name}"
    puts "S3_URL=https://#{@name}.s3-#{@region}.amazonaws.com/"
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
