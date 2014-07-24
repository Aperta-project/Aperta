class PaperUnlockerWorker
  include Sidekiq::Worker

  sidekiq_options queue: :paper_unlocker

  DEFERRED_TIME = 2.minutes

  def perform(paper_id, deferred=false)
    paper = Paper.find(paper_id)
    if deferred
      clear_unlock_jobs_for(paper_id)
      self.class.perform_in(DEFERRED_TIME, paper_id)
    else
      paper.unlock if paper.present?
    end
  end

  private

  def scheduled_jobs
    Sidekiq::ScheduledSet.new.select do |j|
      j.queue == queue_name && j.display_class == self.class.name
    end
  end

  def clear_unlock_jobs_for(paper_id)
    scheduled_jobs.each do |job|
      if job.args.first == paper_id
        job.delete
      end
    end
  end

  def queue_name
    self.class.get_sidekiq_options["queue"].to_s
  end
end
