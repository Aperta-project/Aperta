# Migration to convert newlines to break tags in tech check bodies

namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It goes through every tech check body and converts newlines to break tags'
      task convert_tech_check_bodies: :environment do
        dry = ENV['DRY_RUN'] == 'true'

        task_type = "PlosBioTechCheck::ChangesForAuthorTask"
        body_keys = %w(initialTechCheckBody finalTechCheckBody revisedTechCheckBody)

        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.where.not(publishing_state: inactive_states).pluck(:id)

        tasks = Task.where(type: task_type).where(paper_id: current_papers).all
        tasks = tasks.select { |task| task.body.is_a? Hash }

        count = 0
        tasks.each do |task|
          body = task.body
          next unless body

          body_keys.each do |key|
            text = body[key]
            next unless text

            newlines = text.count("\n")
            next if newlines.zero?

            count += 1
            body[key] = text.gsub("\n", "<br>")
            task.body = body

            if dry
              puts "Converted Paper [#{task.paper_id}] Task [#{task.id}] #{key.titleize} Newlines [#{newlines}]"
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
