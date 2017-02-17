namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-8416 fix forensic activity feed items that have the incorrect publishing state
    DESC
    task fix_forensic_feed: :environment do
      Paper.find_each do |paper|
        forensic_items = paper.activities.where(feed_name: 'forensic').order(created_at: :asc)
        next if forensic_items.empty?
        current_activity_state = forensic_items.last.activity_key.split(".").last
        if current_activity_state == paper.publishing_state
          next # Skip this paper's forensic feed--its already been migrated
        end
        forensic_items.each_with_index do |item, i|
          if item != forensic_items.last
            next_item = forensic_items[i + 1]
            item.update!(
              activity_key: next_item.activity_key,
              message: next_item.message
            )
          else
            item.update!(
              activity_key: "paper.state_changed.#{paper.publishing_state}",
              message: "Paper state changed to #{paper.publishing_state}"
            )
          end
        end
      end
    end
  end
end
