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

# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker

  # Retries here are would be confusing.  A paper could revert to an older
  # state hours or days after it was fixed.
  sidekiq_options retry: false

  # +download+ schedules a background job to download the paper's
  # manuscript at the provided url, on behalf of the given user.
  # ihat will post to the given callback url when the job is finished
  def self.download(paper, url, current_user)
    if url.blank?
      raise(ArgumentError, "Url must be provided (received a blank value)")
    end
    paper.update_attribute(:processing, true)
    perform_async(
      paper.id,
      url,
      current_user.id
    )
  end

  # +perform+ should not be called directly, but by the background job
  # processor. Use the DownloadManuscriptWorker.download
  # instead when calling from application code.
  def perform(paper_id, download_url, current_user_id)
    paper = Paper.find(paper_id)
    uploaded_by = current_user_id.present? ? User.find(current_user_id) : nil
    paper.download_manuscript!(download_url, uploaded_by: uploaded_by)
  end
end
