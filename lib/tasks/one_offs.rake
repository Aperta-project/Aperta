namespace :one_off do

  desc "migrate existing activity records to hide reviewers from authors"
  task :migrate_participations_activity_to_workflow => :environment do
    Activity.where(activity_key: ["participation.created", "participation.destroyed"]).update_all(feed_name: "workflow")
  end

end
