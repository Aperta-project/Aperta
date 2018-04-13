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

# This serializes an author-safe version of manuscipt manager templates
class PaperTypeSerializer < AuthzSerializer
  attributes :id,
    :paper_type,
    :is_preprint_eligible,
    :task_names

  # Get titles of custom cards that are submission tasks
  # This is used by the client to see if the manuscript manaager template
  # has a Preprint Posting card, to decide whether to draw a preprint offer
  # overlay after the manuscript is first uploaded
  def task_names
    object.task_templates.select(&:required_for_submission).map(&:title)
  end

  private

  def can_view?
    # The purpose of this serializer is to be safe for authors to view.
    true
  end
end
