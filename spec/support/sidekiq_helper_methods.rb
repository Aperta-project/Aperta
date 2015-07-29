module SidekiqHelperMethods

  def process_sidekiq_jobs
    while Sidekiq::Worker.jobs.values.flatten.size > 0
      Sidekiq::Worker.jobs.each_pair do |klass,job_data|
        klass.drain
      end

      sleep 1
    end
  end
  
end
