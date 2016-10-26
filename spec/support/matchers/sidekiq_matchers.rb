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
    "expected that #{actual} would have a mailer job queued with #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not a have a mailer job queued with #{expected}"
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
