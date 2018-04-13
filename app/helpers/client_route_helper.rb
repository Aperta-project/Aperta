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

module ClientRouteHelper
  def client_dashboard_url(*args)
    root_url(*args)
  end

  def client_paper_task_url(paper, task)
    "#{root_url}papers/#{paper.to_param}/tasks/#{task.to_param}"
  end

  def client_paper_url(paper, params = {})
    query = "?#{params.to_query}" if params.present?

    "#{root_url}papers/#{paper.to_param}/#{query}"
  end

  def client_discussion_url(discussion, paper, params = {})
    query = "?#{params.to_query}" if params.present?

    "#{root_url}papers/#{paper.to_param}/discussions/" \
      "#{discussion.to_param}/#{query}"
  end

  def client_show_invitation_url(token:)
    "#{root_url}invitations/#{token}"
  end

  def client_show_correspondence_url(correspondence)
    paper = correspondence.paper
    "/papers/#{paper.short_doi}/correspondence/viewcorrespondence/#{correspondence.id}"
  end

  def client_coauthor_url(token:)
    "#{root_url}co_authors_token/#{token}"
  end
end
