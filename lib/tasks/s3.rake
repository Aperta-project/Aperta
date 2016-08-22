require 'securerandom'
require 'aws-sdk'
require 'create_bucket_service'

namespace :s3 do
  desc <<-DESC.strip_heredoc
          Creates a new S3 bucket, a new AWS user account, and a new policy
          which grants the user permission to perform any action on the bucket.

          All 3 entities will share the same name. The name can be specified
          using an environment variable:
             `BUCKET_NAME=the-best-bucket rake s3:create_bucket`
          If it's not supplied, a bucket name will be generated for you.
          It will take the form,
             `tahi-user-dev-\#{uuid}`
       DESC
  task create_bucket: :environment do
    CreateBucketService.new(name: ENV['BUCKET_NAME']).call
  end
end
