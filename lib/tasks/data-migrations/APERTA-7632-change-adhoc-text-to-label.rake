namespace :data do
  namespace :migrate do
    namespace :adhoc_tasks do
      desc "Changes 'text' type blocks into 'label' blocks"
      task change_text_blocks_to_label: :environment do
        count = 0
        Task.where(type: 'Task').find_each do |task|
          task.body.each do |body_blocks|
            body_blocks.each do |block_item|
              if block_item["type"] == "text"
                block_item["type"] = "adhoc-label"
                count += 1
              end
            end
          end
          task.save
        end

        puts "Migrated #{count} text blocks to adhoc-label"
      end
    end
  end
end
