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

# Prepare a manuscript for Ihat
class ProcessManuscriptWorker
  include Sidekiq::Worker

  # Retrying this could be confusing. If the user has fixed the problem by uploading
  # a new version, this would overwrite that when processed hours or days later.
  sidekiq_options :retry => false

  def perform(manuscript_attachment_id)
    manuscript_attachment = ManuscriptAttachment.find(manuscript_attachment_id)
    # Occasionally we don't have the file details from CarrierWave committed to
    # the database when this method kicks off. In that case, m_a.file.file will
    # be nil. When that happens, a new database lookup after 1 second typically
    # returns complete information. To be safe, we'll make five attempts, but I
    # have never seen this take more than 1.
    counter = 0
    while manuscript_attachment.file.file.nil? && counter < 5
      # logger.info 'Attachment not ready yet, retrying in 1 second'
      counter += 1
      sleep 1
      manuscript_attachment = ManuscriptAttachment.find(manuscript_attachment_id)
    end
    paper = manuscript_attachment.paper
    epub_stream = get_epub(paper)
    IhatJobRequest.request_for_epub(
      epub: epub_stream,
      url: manuscript_attachment.pending_url,
      metadata: {
        paper_id: paper.id,
        user_id: manuscript_attachment.uploaded_by_id })
  end

  private

  def get_epub(paper)
    converter = EpubConverter.new(
      paper,
      paper.creator)
    converter.epub_stream.string
  end
end
