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

class RouterUploadStatusWorker
  include Sidekiq::Worker

  # retry 12 times every 10 seconds, and don't add failed jobs to the dead job queue
  sidekiq_options retry: 12, dead: false
  sidekiq_retry_in { 10.seconds }

  sidekiq_retries_exhausted do |msg|
    export_delivery = TahiStandardTasks::ExportDelivery.find(msg['args'].first)
    export_delivery.delivery_failed!('Time out waiting for export service')
  end

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
    service = TahiStandardTasks::ExportService.new export_delivery: export_delivery
    result = service.export_status

    case result[:job_status]
    when "PENDING"
      raise TahiStandardTasks::ExportService::StatusError, "Job pending"
    when "SUCCESS"
      export_delivery.delivery_succeeded!
      # check for published status (for preprints only)
      RouterPostStatusWorker.perform_in(1.hour, export_delivery.id) if export_delivery.destination == 'preprint'
    else
      export_delivery.delivery_failed!(result[:job_status_description])
    end
  end
end
