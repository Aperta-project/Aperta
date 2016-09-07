# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :paper_tracker_query do
      desc 'Updates search of SUBMITTED to VERSION DATE'
      task update_submitted_search: :environment do
        # The option of 'c' is passed in here to make the search case sensitive.
        # This is so we don't inadvertently change saved searches that are
        # searching for a paper status of 'submitted'.
        PaperTrackerQuery.update_all("query = regexp_replace(query, 'SUBMITTED', 'VERSION DATE', 'c')")
      end
    end
  end
end
