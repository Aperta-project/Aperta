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

# Snapshot::AttachmentSerializer is responsible for generically
# snapshotting Attachment models.
#
# Since multiple kinds of attachments re-use the Attachment model as a
# base-class this serializer will snapshot all of the properties, even if they
# are unused.
#
# It is the responsibility of the whomever is consuming these attachment snapshots to use or not use
# the values captured.
#
class Snapshot::AttachmentSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    properties = [
      snapshot_property('caption', 'text', model.caption),
      snapshot_property('category', 'text', model.category),
      snapshot_property('file', 'text', model.filename),
      snapshot_property('file_hash', 'text', model.file_hash),
      snapshot_property('label', 'text', model.label),
      snapshot_property('publishable', 'boolean', model.publishable),
      snapshot_property('status', 'text', model.status),
      snapshot_property('title',  'text', model.title),
      snapshot_property('url', 'url', model.public_url),
      snapshot_property('owner_type', 'text', model.owner_type),
      snapshot_property('owner_id', 'integer', model.owner_id)
    ]
    properties
  end
end
