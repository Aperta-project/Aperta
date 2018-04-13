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

# AdHocTask is a user-customizeable task type
class AdHocTask < Task
  DEFAULT_TITLE = 'Ad-hoc for Staff Only'.freeze

  # Avoid resetting adhoc task title and role
  def self.restore_defaults
  end

  # type can be "attachments", "text", "email", "h1"
  # for adhoc tasks, the body is composed of an array of 'blocks',
  # each of which are composed of an array of items.
  # There can be more than one item in a block, but every item will have the same "type",
  # hence we can see what 'type' the block is by just looking at the first item.
  # [
  #   [{ "type" => "text", "value" => "foo" }],
  #   [{ "type" => "checkbox", "value" => "foo" }
  #    { "type" => "checkbox", "value" => "bar" }
  #   ],
  #   [{ "type" => "attachments", "value" => "Please select a file." }]
  # ]
  def blocks(type)
    body.select { |b| b[0]["type"] == type }
  end
end
