# Migration to convert newlines to break tags in tech check bodies

namespace :data do
  namespace :migrate do
    namespace :sanitize_database_html do
      desc 'It goes through every tech check body and converts newlines to break tags'
      task convert_tech_check_bodies: :environment do
        dry = ENV['DRY_RUN'] == 'true'
        task_type = "PlosBioTechCheck::ChangesForAuthorTask"
        body_keys = %w(initialTechCheckBody finalTechCheckBody revisedTechCheckBody)

        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.where.not(publishing_state: inactive_states).all
        paper_ids = current_papers.map(&:id)

        tasks = Task.where(type: task_type).where(paper_id: paper_ids).all
        tasks = tasks.select { |task| task.body.is_a? Hash }

        count = 0
        tasks.each do |task|
          body = task.body
          next unless body
          body_keys.each do |key|
            before = body[key]
            next unless before && before =~ /\n/
            count += 1
            after = before.gsub("\n", "<br>")
            body[key] = after
            task.body = body
            if dry
              puts "Converted #{task.paper_id} #{task.id} #{key} #{before.size} -> #{after.size}"
            else
              task.save
            end
          end
        end
        puts "Converted tech check bodies [#{count}]"
      end
    end
  end
end
