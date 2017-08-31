require 'sidekiq'
require 'sidekiq/scheduler'

# if TahiEnv.ithenticate_enabled?
#   Sidekiq.configure_server do |config|
#     config.on(:startup) do
#       Sidekiq.set_schedule(
#         'SimilarityCheckUpdate',
#         'every' => ['10s'],
#         'class' => 'SimilarityCheckUpdateWorker'
#       )
#     end
#   end
# end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.set_schedule(
      'ScheduledEvents',
      'every' => ['1m'],
      'class' => 'ScheduledEventsWorker'
    )
  end
end
