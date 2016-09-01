# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :paper_tracker_query do
      desc 'Updates search of SUBMITTED to VERSION DATE'
      task update_submitted_search: :environment do
        PaperTrackerQuery.update_all("query = regexp_replace(query, 'SUBMITTED', 'VERSION DATE', 'c')")
      end
    end
  end
end
