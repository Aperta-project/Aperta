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

# This creates the json representation of group authors for use in
# versioning and diffing. Triggered on the paper submitted event,
# via the Snapshot::AuthorTaskSerializer.
class Snapshot::GroupAuthorSerializer < Snapshot::BaseSerializer
  private

  # Disabling ABC checking because this is one method that returns a
  # list of properties; it's not conceptually complex.
  # rubocop:disable Metrics/AbcSize
  def snapshot_properties
    [
      snapshot_property("id", "integer", model.id),
      snapshot_property(
        "contact_first_name", "text", model.contact_first_name),
      snapshot_property("contact_last_name", "text", model.contact_last_name),
      snapshot_property(
        "contact_middle_name", "text", model.contact_middle_name),
      snapshot_property("position", "integer", model.position),
      snapshot_property("contact_email", "text", model.contact_email),
      snapshot_property("name", "text", model.name),
      snapshot_property("initial", "text", model.initial)
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
