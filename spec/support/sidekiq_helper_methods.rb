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
