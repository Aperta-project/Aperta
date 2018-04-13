# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'securerandom'
require 'aws-sdk'

# rubocop:disable Rails/Output
class CreateBucketService
  PREFIX = 'tahi-user-dev'

  def initialize(name: nil)
    @region = 'us-west-1' # northern california
    STDERR.write("Please enter an AWS access key of a user with permissions \
to set up a new bucket: ")
    access_key_id = STDIN.gets.chomp

    STDERR.write("Please enter the SECRET key of the same access key: ")
    secret_access_key = STDIN.gets.chomp

    STDERR.write("Please enter the domain that will be accessing this bucket \
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
    @updating = @bucket.exists?
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
    if @updating
      STDERR.write("Updating an existing bucket.\n")
      STDERR.write("Do you want to create a new access key? (y/n [default])? ")
      new_bucket = STDIN.gets.chomp
      return unless new_bucket.downcase[0] == 'y'
    end
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
          },
          {
            allowed_headers: ["*"],
            allowed_origins: [@allowed_origins],
            allowed_methods: ['GET'],
            max_age_seconds: 3600,
            expose_headers: [
              'Accept-Ranges',
              'Content-Range',
              'Content-Encoding',
              'Content-Length'
            ]
          }
        ]
      }
    )
  end

  def print_env
    if @key_pair.present?
      puts "AWS_ACCESS_KEY_ID=#{@key_pair.access_key_id}"
      puts "AWS_SECRET_ACCESS_KEY=#{@key_pair.secret}"
    end
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
