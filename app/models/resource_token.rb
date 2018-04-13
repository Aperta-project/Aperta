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

# ResourceToken is a class to link internal models to external resources. It is
# used to when we want to hand out a permalink for an asset that is hosted on S3
# that requires a temporary signed url.
class ResourceToken < ActiveRecord::Base
  include ViewableModel
  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :owner, polymorphic: true

  def url(version = nil)
    chosen_url = default_url
    chosen_url = version_urls[version.to_s] if version
    if chosen_url
      owner_type.constantize.authenticated_url_for_key(chosen_url)
    end
  end
end
