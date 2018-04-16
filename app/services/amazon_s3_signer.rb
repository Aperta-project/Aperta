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

# This Service class help us to generate the appropriate params required
# for a direct upload to Amazon S3
class AmazonS3Signer
  def initialize(file_name:, file_path:, content_type:)
    @file_name = file_name
    @file_path = file_path
    @content_type = content_type
    @expires = 1.day.from_now
  end

  def params # rubocop:disable Metrics/MethodLength
    {
      acl: 'public-read',
      awsaccesskeyid: ENV['AWS_ACCESS_KEY_ID'],
      bucket: ENV['S3_BUCKET'],
      expires: @expires,
      key: "#{@file_path}/#{@file_name}",
      policy: policy,
      signature: signature,
      success_action_status: '201',
      'Content-Type' => @content_type,
      'Cache-Control' => 'max-age=630720000, public'
    }
  end

  private

  def signature
    Base64.strict_encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        ENV['AWS_SECRET_ACCESS_KEY'],
        policy
      )
    )
  end

  def policy # rubocop:disable Metrics/MethodLength
    Base64.strict_encode64(
      {
        expiration: @expires,
        conditions: [
          { bucket: ENV['S3_BUCKET'] },
          { acl: 'public-read' },
          { expires: @expires },
          { success_action_status: '201' },
          ['starts-with', '$key', ''],
          ['starts-with', '$Content-Type', ''],
          ['starts-with', '$Cache-Control', ''],
          ['content-length-range', 0, 524_288_000]
        ]
      }.to_json
    )
  end
end
