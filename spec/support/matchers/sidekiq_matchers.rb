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

# MyWorker.should have_queued_job(2)
# Collector.should have_queued_job_at(Time.new(2012,1,23,14,00),2)

# have_queued_mailer_job is different than have_queued_job since Sidekiq stores
# more meta-information in the job's args than a normal worker when queueing
# up mailers.
#
# Here's an exampl using it:
#   expect(Sidekiq::DelayedMailer).to have_queued_mailer_job(
#     PlosBioTechCheck::ChangesForAuthorMailer,
#     :notify_changes_for_author,
#     [{author_id: paper.creator.id, task_id: task.id}
RSpec::Matchers.define :have_queued_mailer_job do |*expected|
  match do |actual|
    actual.jobs.any? { |job| Array(expected) == YAML.load(job["args"].first) }
  end

  failure_message do |actual|
    <<-MESSAGE.strip_heredoc
      expected that #{actual} would have a mailer job queued with #{expected}
      Actual job queue contents:
        #{actual.jobs.inspect}
    MESSAGE
  end

  failure_message_when_negated do |actual|
    <<-MESSAGE.strip_heredoc
      expected that #{actual} would not a have a mailer job queued with #{expected}
      Actual job queue contents:
        #{actual.jobs.inspect}
    MESSAGE
  end

  description do
    "have a mailer job queued with #{expected}"
  end
end

RSpec::Matchers.define :have_queued_job do |*expected|
  match do |actual|
    actual.jobs.any? { |job| Array(expected) == job["args"] }
  end

  failure_message do |actual|
    "expected that #{actual} would have a job queued with #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not a have a job queued with #{expected}"
  end

  description do
    "have a job queued with #{expected}"
  end
end

RSpec::Matchers.define :have_queued_job_at do |at,*expected|
  match do |actual|
    actual.jobs.any? { |job| job["args"] == Array(expected) && job["at"].to_i == at.to_i }
  end

  failure_message do |actual|
    "expected that #{actual} would have a job queued with #{expected} at time #{at}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not a have a job queued with #{expected} at time #{at}"
  end

  description do
    "have a job queued with #{expected} at time #{at}"
  end
end

RSpec::Matchers.define :have_empty_queue do |_|
  match do |actual|
    actual.jobs.empty?
  end

  failure_message do |actual|
    "expected that #{actual} would be empty, but had #{actual.jobs.count} jobs: \n #{actual.jobs.inspect}"
  end

  failure_message_when_negated do |_actual|
    "Please use :have_queued_job to test that your job was successfully queued"
  end

  match_when_negated do |_actual|
    false
  end

  description do
    "have an empty queue"
  end
end
