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

if ENV.has_key? 'AWS_ACCESS_KEY_ID'
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: TahiEnv.aws_access_key_id,
      aws_secret_access_key: TahiEnv.aws_secret_access_key,
      region: TahiEnv.aws_region
    }
    config.fog_directory  = TahiEnv.s3_bucket
    config.fog_public     = false
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
    config.fog_authenticated_url_expiration = 6.days
    config.cache_dir = Rails.root.join('public/uploads/tmp/carrierwave').to_s
  end
else
  Rails.logger.warn "AWS_ACCESS_KEY_ID not found in ENV; CarrierWave is disabled."
end
