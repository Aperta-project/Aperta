module SidekiqHelperMethods

  def process_sidekiq_jobs
    while Sidekiq::Worker.jobs.values.flatten.size > 0
      Sidekiq::Worker.jobs.each_pair do |klass,job_data|
        klass.drain
      end

      # Without this sleep Sidekiq may not see a job that was getting queued up
      # during the processing the current job.
      sleep 0.25
    end
  end

end
