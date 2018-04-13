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

class RouterPostStatusWorker
  include Sidekiq::Worker

  # retry once per hour (10 days total), then send to dead job queue
  sidekiq_options retry: 240
  sidekiq_retry_in { 1.hour }

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
    service = TahiStandardTasks::ExportService.new export_delivery: export_delivery
    result = service.export_status
    Rails.logger.warn("WARNING: Router returned: #{result[:job_status_description]}") if result[:job_status] != 'SUCCESS'
    raise TahiStandardTasks::ExportService::StatusError, "Waiting for preprint post status" unless result[:preprint_posted]
    export_delivery.posted!
  end
end
