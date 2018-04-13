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

# This creates the json representation of individual authors for use
# in versioning and diffing. Triggered on the paper submitted event,
# via the Snapshot::AuthorTaskSerializer.
class Snapshot::AuthorSerializer < Snapshot::BaseSerializer
  private

  # Disabling ABC checking because this is one method that returns a
  # list of properties; it's not conceptually complex.
  # rubocop:disable Metrics/AbcSize
  def snapshot_properties
    [
      snapshot_property("id", "integer", model.id),
      snapshot_property("first_name", "text", model.first_name),
      snapshot_property("last_name", "text", model.last_name),
      snapshot_property("middle_initial", "text", model.middle_initial),
      snapshot_property("position", "integer", model.position),
      snapshot_property("email", "text", model.email),
      snapshot_property("department", "text", model.department),
      snapshot_property("title", "text", model.title),
      snapshot_property("affiliation", "text", model.affiliation),
      snapshot_property(
        "secondary_affiliation", "text", model.secondary_affiliation),
      snapshot_property("ringgold_id", "text", model.ringgold_id),
      snapshot_property(
        "secondary_ringgold_id", "text", model.secondary_ringgold_id)
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
