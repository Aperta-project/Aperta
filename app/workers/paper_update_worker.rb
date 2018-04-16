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
require_dependency 'notifier'

# paper update worker perfrom async
class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper, :epub_stream

  # Retries here are would be confusing.  A paper could revert to an older
  # state hours or days after it was fixed.
  sidekiq_options retry: false

  # define an error class for Ihat jobs
  class IhatJobError < StandardError
  end

  def perform(ihat_job_params)
    params = ihat_job_params.with_indifferent_access
    job_response = IhatJobResponse.new(params)
    @paper = Paper.find(job_response.paper_id)
    begin
      if job_response.errored?
        # adding this since processing doesn't ever get updated to false
        # when we are replacing(updating) a file on an existing paper
        @paper.update!(processing: false)
        @paper.file.update(status: Attachment::STATUS_ERROR)

        # this will by pass the if: :changes_committed? in the notifiable.rb
        # in order to trigger the pusher method that gets our record updated
        # from the server side to our client
        Notifier.notify(event: 'paper:updated',
                        data: @paper.event_payload(action: 'updated'))
        raise IhatJobError, job_response.job_state
      end
    # only throw the exception to notify bugsnag, then proceed
    rescue IhatJobError => e
      Bugsnag.notify(e)
    end
    if job_response.completed?
      @epub_stream = Faraday.get(
        job_response.format_url(:epub)
      ).body
      body = TahiEpub::Zip.extract(stream: epub_stream, filename: 'body').force_encoding("UTF-8") rescue nil
      @paper.update!(body: body, processing: false)
      Notifier.notify(event: "paper:data_extracted", data: { record: job_response })
      Notifier.notify(event: 'paper:updated', data: @paper.event_payload(action: 'updated'))
    end
  end

end
