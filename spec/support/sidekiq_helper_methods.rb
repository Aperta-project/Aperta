module SidekiqHelperMethods
  class NoSidekiqJobError < ::StandardError ; end

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
