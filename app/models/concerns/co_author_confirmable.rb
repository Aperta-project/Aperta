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

# Authors and group authors are listed by the manuscript's creator --
# but what if they're attempting to gain credibility by adding
# important coauthors who were not actually involved in the work? This
# module extends author-like models to track when and how authors
# confirm (or refute) their contributions to a manuscript.
module CoAuthorConfirmable
  extend ActiveSupport::Concern

  included do
    validates :co_author_state,
      inclusion: { in: %w[confirmed unconfirmed refuted],
                   message: "must be confirmed, unconfirmed or refuted" },
      allow_nil: true
  end

  def co_author_confirmed?
    co_author_state == 'confirmed'
  end

  def co_author_refuted?
    co_author_state == 'refuted'
  end

  def co_author_confirmed!
    # not every author has an associated user, so this is a crappy workaround
    update_coauthor_state('confirmed', nil)
  end

  def update_coauthor_state(status, user_id)
    update_attributes!(
      co_author_state: status,
      co_author_state_modified_by_id: user_id,
      co_author_state_modified_at: Time.now.utc
    )
  end
end
