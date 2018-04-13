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

class OrcidAccountSerializer < AuthzSerializer
  attributes :id,
    :identifier,
    :name,
    :profile_url,
    :status,
    :oauth_authorize_url,
    :orcid_connect_enabled

  private

  def include_name?
    is_current_user?
  end

  def include_oauth_authorize_url?
    is_current_user?
  end

  def include_status?
    is_current_user?
  end

  def is_current_user?
    current_user.id == object.user_id
  end

  def orcid_connect_enabled
    TahiEnv.orcid_connect_enabled?
  end

  def can_view?
    # See above. Contains no sensitive information. I don't know why this was
    # implemented like this, but it was. -EGH
    true
  end
end
