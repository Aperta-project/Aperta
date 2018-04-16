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

module SidekiqHelperMethods
  class NoSidekiqJobError < ::StandardError ; end

  # process_sidekiq_jobs processes queued up background jobs. It does so in a way
  # that allows for the two threads that run during feature specs to have ample
  # time and opportunity to queue up jobs (and also see, then process jobs in
  # the queue). It works with jobs that queue up other jobs as well.
  def process_sidekiq_jobs(tries = 5)
    return if tries <= 0
    loop do
      raise NoSidekiqJobError if Sidekiq::Worker.jobs.values.flatten.empty?
      Sidekiq::Worker.jobs.keys.map(&:drain)
    end
  rescue NoSidekiqJobError
    sleep 0.5
    process_sidekiq_jobs tries - 1
  end

end
