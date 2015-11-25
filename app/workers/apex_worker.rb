class ApexWorker
  include Sidekiq::Worker

  def perform(filename, filepath)
    # Place other Apex tasks here.
    # Eventually the filename and filepath will not need to be passed in to the worker.
    FtpUploaderService.new(filename: filename, filepath: filepath).upload
  end
end
