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

# Serializer for Roles and Permissions
class PermissionsSerializer < AuthzSerializer
  def serializable_hash
    object.to_h.merge(id: id).as_json
  end

  # The +id+ here is hard-coded to side-loading. It works in conjuction with
  # the`has_one :permissions, include: true, embed: :ids` on the
  # CurrentUserSerializer.
  #
  # This is because ember-data expects resources on the server to have numeric
  # IDs by default otherwise it gets angry. Rather than work against the grain
  # of ember-data right now we're working with it. This may change in upcoming
  # work if this has cause other issues. Perhaps to not use ember-data for
  # permissions on the client-side (maybe restless) and then we could get rid
  # of a fake id.
  def id
    1
  end
end
